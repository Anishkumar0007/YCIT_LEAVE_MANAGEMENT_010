*" ============================================================
*" LOCAL TYPES TAB  (zbp_cit_010_i.clas.locals_def.abap)
*" ABAP Cloud 2025
*"
*" BDEF Aliases:
*"   ZCIT_010_I  alias LeaveHeader  -> mapped-leaveheader
*"                                  -> failed-leaveheader
*"                                  -> reported-leaveheader
*"   ZCIT_010_O  alias LeaveItems   -> mapped-leaveitems
*"                                  -> failed-leaveitems
*"                                  -> reported-leaveitems
*"
*" ACTIVATE ORDER (mandatory):
*"   1. Global Class tab
*"   2. THIS tab  (Local Types)
*"   3. Local Implementations tab
*" ============================================================
*
*" ============================================================
*" BUFFER
*" ============================================================
*CLASS lcl_buffer DEFINITION FINAL.
*  PUBLIC SECTION.
*    CLASS-DATA:
*      mt_hdr_create TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
*      mt_hdr_update TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
*      mt_hdr_delete TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
*      mt_itm_create TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY,
*      mt_itm_update TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY,
*      mt_itm_delete TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY.
*
*    CLASS-METHODS clear.
*ENDCLASS.
*
*CLASS lcl_buffer IMPLEMENTATION.
*  METHOD clear.
*    CLEAR: mt_hdr_create, mt_hdr_update, mt_hdr_delete,
*           mt_itm_create, mt_itm_update, mt_itm_delete.
*  ENDMETHOD.
*ENDCLASS.
*
*
*" ============================================================
*" HEADER HANDLER DEFINITION
*" ============================================================
*CLASS lhc_leaveheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
**  METHODS markasgranted FOR MODIFY
**  IMPORTING keys FOR ACTION LeaveHeader~MarkAsGranted
**  RESULT result.
**
**METHODS markasrejected FOR MODIFY
**  IMPORTING keys FOR ACTION LeaveHeader~MarkAsRejected
**  RESULT result.
*
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE leaveheader.
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE leaveheader.
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE leaveheader.
*    METHODS read FOR READ
*      IMPORTING keys FOR READ leaveheader RESULT result.
*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK leaveheader.
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations
*                FOR leaveheader RESULT result.
*    METHODS rba_leaveitems FOR READ
*      IMPORTING keys_rba FOR READ leaveheader\_leaveitems
*      FULL result_requested RESULT result LINK association_links.
*    METHODS cba_leaveitems FOR MODIFY
*      IMPORTING entities_cba FOR CREATE leaveheader\_leaveitems.
*ENDCLASS.
*
*
*" ============================================================
*" ITEM HANDLER DEFINITION
*" ============================================================
*CLASS lhc_leaveitems DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE leaveitems.
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE leaveitems.
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE leaveitems.
*    METHODS read FOR READ
*      IMPORTING keys FOR READ leaveitems RESULT result.
*    METHODS rba_header FOR READ
*      IMPORTING keys_rba FOR READ leaveitems\_header
*      FULL result_requested RESULT result LINK association_links.
*ENDCLASS.
*
*
*" ============================================================
*" SAVER DEFINITION
*" ============================================================
*CLASS lsc_zcit_010_i DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*    METHODS finalize          REDEFINITION.
*    METHODS check_before_save REDEFINITION.
*    METHODS save              REDEFINITION.
*    METHODS cleanup           REDEFINITION.
*    METHODS cleanup_finalize  REDEFINITION.
*ENDCLASS.
*" ============================================================
*" LOCAL IMPLEMENTATIONS TAB (zbp_cit_010_i.clas.locals_imp.abap)
*" ABAP Cloud 2025
*"
*" Key ABAP Cloud 2025 standards applied:
*"  - No MOVE-CORRESPONDING entity->DB  (RAP internal fields dump)
*"  - No READ ENTITIES inside handler   (recursive call = dump)
*"  - No DATA() inline in nested loops  (stale values = dump)
*"  - No cl_system_uuid (use xco_cp)    (CX_UUID_ERROR = dump)
*"  - No sy-subrc after SELECT for UUID (use INTO + check)
*"  - Timestamps via cl_abap_context_info (Cloud-released API)
*"  - FOR ALL ENTRIES guarded by CHECK IS NOT INITIAL
*"  - Explicit CLEAR before each work variable reuse
*" ============================================================
*
*CLASS lhc_leaveheader IMPLEMENTATION.
*
*" ================================================================
*" AUTHORIZATION
*" ================================================================
*  METHOD get_instance_authorizations.
*    " Leave empty = fully authorized
*    " Add AUTHORITY-CHECK here if needed
*  ENDMETHOD.
*
*  METHOD lock.
*    " Optimistic locking via total etag (LocalLastChangedAt)
*    " handled by the framework automatically
*  ENDMETHOD.
*
*" ================================================================
*" CREATE LeaveHeader
*" leave_id is manually entered by the user.
*" Validate it is not initial and not a duplicate.
*" ================================================================
*
**  METHOD markasgranted.
**
**  LOOP AT keys INTO DATA(ls_key).
**
**    SELECT SINGLE *
**      FROM zcit_010_hdr
**      WHERE leave_id = @ls_key-LeaveID
**      INTO @DATA(ls_hdr).
**
**    IF sy-subrc <> 0.
**      CONTINUE.
**    ENDIF.
**
**    ls_hdr-status = 'GRANTED'.
**
**    ls_hdr-local_last_changed_by = sy-uname.
**    GET TIME STAMP FIELD ls_hdr-local_last_changed_at.
**    GET TIME STAMP FIELD ls_hdr-last_changed_at.
**
**    APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.
**
**    result = VALUE #( ( %tky = ls_key-%tky ) ).
**
**  ENDLOOP.
**
**ENDMETHOD.
**
**
**
**METHOD markasrejected.
**
**  LOOP AT keys INTO DATA(ls_key).
**
**    SELECT SINGLE *
**      FROM zcit_010_hdr
**      WHERE leave_id = @ls_key-LeaveID
**      INTO @DATA(ls_hdr).
**
**    IF sy-subrc <> 0.
**      CONTINUE.
**    ENDIF.
**
**    ls_hdr-status = 'REJECTED'.
**
**    ls_hdr-local_last_changed_by = sy-uname.
**    GET TIME STAMP FIELD ls_hdr-local_last_changed_at.
**    GET TIME STAMP FIELD ls_hdr-last_changed_at.
**
**    APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.
**
**    result = VALUE #( ( %tky = ls_key-%tky ) ).
**
**  ENDLOOP.
**
**ENDMETHOD.
**
*
*
*
*
*  METHOD create.
*    " Declare ALL variables outside loop - ABAP Cloud 2025 rule
*    DATA ls_hdr       TYPE zcit_010_hdr.
*    DATA lv_ts        TYPE timestamp.
*    DATA lv_exists    TYPE zcit_010_hdr-leave_id.
*
*    LOOP AT entities INTO DATA(ls_entity).
*      CLEAR: ls_hdr, lv_ts, lv_exists.
*
*      " Validate: leave_id must be provided by user
*      IF ls_entity-leaveid IS INITIAL.
*        APPEND VALUE #(
*          %cid = ls_entity-%cid
*          %msg = new_message_with_text(
*                   severity = if_abap_behv_message=>severity-error
*                   text     = 'Leave ID is mandatory' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-leaveheader.
*        CONTINUE.
*      ENDIF.
*
*      " Validate: duplicate key check
*      SELECT SINGLE leave_id
*        FROM zcit_010_hdr
*        WHERE leave_id = @ls_entity-leaveid
*        INTO @lv_exists.
*      IF sy-subrc = 0.
*        APPEND VALUE #(
*          %cid = ls_entity-%cid
*          %msg = new_message_with_text(
*                   severity = if_abap_behv_message=>severity-error
*                   text     = 'Leave ID already exists' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-leaveheader.
*        CONTINUE.
*      ENDIF.
*
*      " Explicit field assignment - NEVER MOVE-CORRESPONDING entity->DB
*      " (entity has RAP fields %cid/%control/%tky that don't exist in DB)
*      ls_hdr-client      = sy-mandt.
*      ls_hdr-leave_id    = ls_entity-leaveid.
*      ls_hdr-employee_id = ls_entity-employeeid.
*      ls_hdr-leave_type  = ls_entity-leavetype.
*      ls_hdr-start_date  = ls_entity-startdate.
*      ls_hdr-end_date    = ls_entity-enddate.
*      ls_hdr-status      = COND #(
*                             WHEN ls_entity-status IS INITIAL
*                             THEN 'Pending'
*                             ELSE ls_entity-status ).
*
*       IF ls_hdr-status IS INITIAL.
*  ls_hdr-status = 'PENDING'.
*ENDIF.
*
*      " ABAP Cloud 2025: use cl_abap_context_info for user/timestamp
*      ls_hdr-local_created_by      = cl_abap_context_info=>get_user_alias( ).
*      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_hdr-local_created_at      = lv_ts.
*      ls_hdr-local_last_changed_at = lv_ts.
*      ls_hdr-last_changed_at       = lv_ts.
*
*      APPEND ls_hdr TO lcl_buffer=>mt_hdr_create.
*
*      " Populate mapped - links %cid to new key for follow-on ops
*      INSERT VALUE #(
*        %cid    = ls_entity-%cid
*        leaveid = ls_hdr-leave_id
*      ) INTO TABLE mapped-leaveheader.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" UPDATE LeaveHeader
*" ================================================================
*  METHOD update.
*    DATA ls_hdr TYPE zcit_010_hdr.
*    DATA lv_ts  TYPE timestamp.
*
*    LOOP AT entities INTO DATA(ls_entity).
*      CLEAR: ls_hdr, lv_ts.
*
*      " Read existing record to avoid blanking unchanged fields
*      SELECT SINGLE *
*        FROM zcit_010_hdr
*        WHERE leave_id = @ls_entity-leaveid
*        INTO @ls_hdr.
*
*      IF sy-subrc <> 0.
*        APPEND VALUE #( leaveid = ls_entity-leaveid ) TO failed-leaveheader.
*        APPEND VALUE #(
*          leaveid = ls_entity-leaveid
*          %msg    = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text     = 'Leave header not found' )
*        ) TO reported-leaveheader.
*        CONTINUE.
*      ENDIF.
*
*      " Apply only fields the UI explicitly changed
*      IF ls_entity-%control-employeeid = if_abap_behv=>mk-on.
*        ls_hdr-employee_id = ls_entity-employeeid.
*      ENDIF.
*      IF ls_entity-%control-leavetype  = if_abap_behv=>mk-on.
*        ls_hdr-leave_type  = ls_entity-leavetype.
*      ENDIF.
*      IF ls_entity-%control-startdate  = if_abap_behv=>mk-on.
*        ls_hdr-start_date  = ls_entity-startdate.
*      ENDIF.
*      IF ls_entity-%control-enddate    = if_abap_behv=>mk-on.
*        ls_hdr-end_date    = ls_entity-enddate.
*      ENDIF.
*      IF ls_entity-%control-status     = if_abap_behv=>mk-on.
*        ls_hdr-status      = ls_entity-status.
*      ENDIF.
*
*      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_hdr-local_last_changed_at = lv_ts.
*      ls_hdr-last_changed_at       = lv_ts.
*
*      APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" DELETE LeaveHeader
*" ================================================================
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      APPEND VALUE zcit_010_hdr(
*        client   = sy-mandt
*        leave_id = ls_key-leaveid
*      ) TO lcl_buffer=>mt_hdr_delete.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" READ LeaveHeader
*" ABAP Cloud 2025: SELECT directly from DB
*" NEVER use READ ENTITIES inside a handler - causes recursive dump
*" ================================================================
*  METHOD read.
*    CHECK keys IS NOT INITIAL.
*
*    SELECT *
*      FROM zcit_010_hdr
*      FOR ALL ENTRIES IN @keys
*      WHERE leave_id = @keys-leaveid
*      INTO TABLE @DATA(lt_hdr).
*
*    LOOP AT lt_hdr INTO DATA(ls_db).
*      INSERT VALUE #(
*        leaveid            = ls_db-leave_id
*        employeeid         = ls_db-employee_id
*        leavetype          = ls_db-leave_type
*        startdate          = ls_db-start_date
*        enddate            = ls_db-end_date
*        status             = ls_db-status
*        localcreatedby     = ls_db-local_created_by
*        localcreatedat     = ls_db-local_created_at
*        locallastchangedby = ls_db-local_last_changed_by
*        locallastchangedat = ls_db-local_last_changed_at
*        lastchangedat      = ls_db-last_changed_at
*      ) INTO TABLE result.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" READ BY ASSOCIATION LeaveHeader -> LeaveItems
*" ================================================================
*  METHOD rba_leaveitems.
*    DATA lt_itm TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY.
*
*    LOOP AT keys_rba INTO DATA(ls_key).
*      CLEAR lt_itm.
*
*      SELECT *
*        FROM zcit_010_itm
*        WHERE leave_id = @ls_key-leaveid
*        INTO TABLE @lt_itm.
*
*      LOOP AT lt_itm INTO DATA(ls_itm).
*        INSERT VALUE #(
*          source-%key   = ls_key-%key
*          target-leaveid     = ls_itm-leave_id
*          target-leaveitemno = ls_itm-leave_item_no
*        ) INTO TABLE association_links.
*
*        IF result_requested = if_abap_behv=>mk-on.
*          INSERT VALUE #(
*            leaveid            = ls_itm-leave_id
*            leaveitemno        = ls_itm-leave_item_no
*            leavedate          = ls_itm-leave_date
*            daytype            = ls_itm-day_type
*            localcreatedby     = ls_itm-local_created_by
*            localcreatedat     = ls_itm-local_created_at
*            locallastchangedby = ls_itm-local_last_changed_by
*            locallastchangedat = ls_itm-local_last_changed_at
*            lastchangedat      = ls_itm-last_changed_at
*          ) INTO TABLE result.
*        ENDIF.
*      ENDLOOP.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" CREATE BY ASSOCIATION LeaveHeader -> LeaveItems
*" ================================================================
*  METHOD cba_leaveitems.
*    " Declare ALL work variables ONCE outside loops - ABAP Cloud 2025
*    " DATA() inline inside nested loop does NOT reset per iteration
*    DATA ls_itm   TYPE zcit_010_itm.
*    DATA lv_max   TYPE zcit_010_itm-leave_item_no.
*    DATA lv_ts    TYPE timestamp.
*
*    LOOP AT entities_cba INTO DATA(ls_cba).
*      LOOP AT ls_cba-%target INTO DATA(ls_target).
*        CLEAR: ls_itm, lv_max, lv_ts.
*
*        ls_itm-client   = sy-mandt.
*        ls_itm-leave_id = ls_cba-leaveid.
*
*        " Auto-number leave_item_no
*        " Initialize lv_max = 0 so arithmetic is safe if table empty
*        lv_max = 0.
*        SELECT SINGLE MAX( leave_item_no )
*          FROM zcit_010_itm
*          WHERE leave_id = @ls_itm-leave_id
*          INTO @lv_max.
*
*        " Also check items already staged in buffer for same leave_id
*        " so multiple items created in one transaction get sequential numbers
*        LOOP AT lcl_buffer=>mt_itm_create INTO DATA(ls_buf)
*             WHERE leave_id = ls_itm-leave_id.
*          IF ls_buf-leave_item_no > lv_max.
*            lv_max = ls_buf-leave_item_no.
*          ENDIF.
*        ENDLOOP.
*
*        ls_itm-leave_item_no = lv_max + 1.
*        ls_itm-leave_date    = ls_target-leavedate.
*        ls_itm-day_type      = ls_target-daytype.
*
*        ls_itm-local_created_by      = cl_abap_context_info=>get_user_alias( ).
*        ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*        GET TIME STAMP FIELD lv_ts.
*        ls_itm-local_created_at      = lv_ts.
*        ls_itm-local_last_changed_at = lv_ts.
*        ls_itm-last_changed_at       = lv_ts.
*
*        APPEND ls_itm TO lcl_buffer=>mt_itm_create.
*
*        " Populate mapped - links %cid to new composite key
*        INSERT VALUE #(
*          %cid        = ls_target-%cid
*          leaveid     = ls_itm-leave_id
*          leaveitemno = ls_itm-leave_item_no
*        ) INTO TABLE mapped-leaveitems.
*
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
*
*
*" ============================================================
*" ITEM HANDLER IMPLEMENTATION
*" ============================================================
*CLASS lhc_leaveitems IMPLEMENTATION.
*
*" ================================================================
*" CREATE LeaveItems (direct create on item node)
*" ================================================================
*  METHOD create.
*    DATA ls_itm TYPE zcit_010_itm.
*    DATA lv_max TYPE zcit_010_itm-leave_item_no.
*    DATA lv_ts  TYPE timestamp.
*
*    LOOP AT entities INTO DATA(ls_entity).
*      CLEAR: ls_itm, lv_max, lv_ts.
*
*      ls_itm-client   = sy-mandt.
*      ls_itm-leave_id = ls_entity-leaveid.
*
*      lv_max = 0.
*      SELECT SINGLE MAX( leave_item_no )
*        FROM zcit_010_itm
*        WHERE leave_id = @ls_itm-leave_id
*        INTO @lv_max.
*
*      LOOP AT lcl_buffer=>mt_itm_create INTO DATA(ls_buf)
*           WHERE leave_id = ls_itm-leave_id.
*        IF ls_buf-leave_item_no > lv_max.
*          lv_max = ls_buf-leave_item_no.
*        ENDIF.
*      ENDLOOP.
*
*      ls_itm-leave_item_no         = lv_max + 1.
*      ls_itm-leave_date            = ls_entity-leavedate.
*      ls_itm-day_type              = ls_entity-daytype.
*      ls_itm-local_created_by      = cl_abap_context_info=>get_user_alias( ).
*      ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_itm-local_created_at      = lv_ts.
*      ls_itm-local_last_changed_at = lv_ts.
*      ls_itm-last_changed_at       = lv_ts.
*
*      APPEND ls_itm TO lcl_buffer=>mt_itm_create.
*
*      INSERT VALUE #(
*        %cid        = ls_entity-%cid
*        leaveid     = ls_itm-leave_id
*        leaveitemno = ls_itm-leave_item_no
*      ) INTO TABLE mapped-leaveitems.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" UPDATE LeaveItems
*" ================================================================
*  METHOD update.
*    DATA ls_itm TYPE zcit_010_itm.
*    DATA lv_ts  TYPE timestamp.
*
*    LOOP AT entities INTO DATA(ls_entity).
*      CLEAR: ls_itm, lv_ts.
*
*      SELECT SINGLE *
*        FROM zcit_010_itm
*        WHERE leave_id      = @ls_entity-leaveid
*          AND leave_item_no = @ls_entity-leaveitemno
*        INTO @ls_itm.
*
*      IF sy-subrc <> 0.
*        APPEND VALUE #(
*          leaveid     = ls_entity-leaveid
*          leaveitemno = ls_entity-leaveitemno
*        ) TO failed-leaveitems.
*        APPEND VALUE #(
*          leaveid     = ls_entity-leaveid
*          leaveitemno = ls_entity-leaveitemno
*          %msg        = new_message_with_text(
*                          severity = if_abap_behv_message=>severity-error
*                          text     = 'Leave item not found' )
*        ) TO reported-leaveitems.
*        CONTINUE.
*      ENDIF.
*
*      IF ls_entity-%control-leavedate = if_abap_behv=>mk-on.
*        ls_itm-leave_date = ls_entity-leavedate.
*      ENDIF.
*      IF ls_entity-%control-daytype   = if_abap_behv=>mk-on.
*        ls_itm-day_type   = ls_entity-daytype.
*      ENDIF.
*
*      ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_itm-local_last_changed_at = lv_ts.
*      ls_itm-last_changed_at       = lv_ts.
*
*      APPEND ls_itm TO lcl_buffer=>mt_itm_update.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" DELETE LeaveItems
*" ================================================================
*  METHOD delete.
*    LOOP AT keys INTO DATA(ls_key).
*      APPEND VALUE zcit_010_itm(
*        client        = sy-mandt
*        leave_id      = ls_key-leaveid
*        leave_item_no = ls_key-leaveitemno
*      ) TO lcl_buffer=>mt_itm_delete.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" READ LeaveItems
*" ABAP Cloud 2025: SELECT directly - READ ENTITIES = recursive dump
*" ================================================================
*  METHOD read.
*    CHECK keys IS NOT INITIAL.
*
*    SELECT *
*      FROM zcit_010_itm
*      FOR ALL ENTRIES IN @keys
*      WHERE leave_id      = @keys-leaveid
*        AND leave_item_no = @keys-leaveitemno
*      INTO TABLE @DATA(lt_itm).
*
*    LOOP AT lt_itm INTO DATA(ls_db).
*      INSERT VALUE #(
*        leaveid            = ls_db-leave_id
*        leaveitemno        = ls_db-leave_item_no
*        leavedate          = ls_db-leave_date
*        daytype            = ls_db-day_type
*        localcreatedby     = ls_db-local_created_by
*        localcreatedat     = ls_db-local_created_at
*        locallastchangedby = ls_db-local_last_changed_by
*        locallastchangedat = ls_db-local_last_changed_at
*        lastchangedat      = ls_db-last_changed_at
*      ) INTO TABLE result.
*    ENDLOOP.
*  ENDMETHOD.
*
*
*" ================================================================
*" READ BY ASSOCIATION LeaveItems -> LeaveHeader
*" ================================================================
*  METHOD rba_header.
*    CHECK keys_rba IS NOT INITIAL.
*
*    SELECT *
*      FROM zcit_010_itm
*      FOR ALL ENTRIES IN @keys_rba
*      WHERE leave_id      = @keys_rba-leaveid
*        AND leave_item_no = @keys_rba-leaveitemno
*      INTO TABLE @DATA(lt_itm).
*
*    LOOP AT lt_itm INTO DATA(ls_itm).
*      CHECK ls_itm-leave_id IS NOT INITIAL.
*
*      READ TABLE keys_rba INTO DATA(ls_key)
*           WITH KEY leaveid     = ls_itm-leave_id
*                    leaveitemno = ls_itm-leave_item_no.
*
*      INSERT VALUE #(
*        source-%key      = ls_key-%key
*        target-leaveid   = ls_itm-leave_id
*      ) INTO TABLE association_links.
*
*      IF result_requested = if_abap_behv=>mk-on.
*        SELECT SINGLE *
*          FROM zcit_010_hdr
*          WHERE leave_id = @ls_itm-leave_id
*          INTO @DATA(ls_hdr).
*
*        IF sy-subrc = 0.
*          INSERT VALUE #(
*            leaveid            = ls_hdr-leave_id
*            employeeid         = ls_hdr-employee_id
*            leavetype          = ls_hdr-leave_type
*            startdate          = ls_hdr-start_date
*            enddate            = ls_hdr-end_date
*            status             = ls_hdr-status
*            localcreatedby     = ls_hdr-local_created_by
*            localcreatedat     = ls_hdr-local_created_at
*            locallastchangedby = ls_hdr-local_last_changed_by
*            locallastchangedat = ls_hdr-local_last_changed_at
*            lastchangedat      = ls_hdr-last_changed_at
*          ) INTO TABLE result.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
*
*
*" ============================================================
*" SAVER IMPLEMENTATION
*" ============================================================
*CLASS lsc_zcit_010_i IMPLEMENTATION.
*
*  METHOD finalize.
*  ENDMETHOD.
*
*  METHOD check_before_save.
*    " Validate mandatory fields before DB persist
*    LOOP AT lcl_buffer=>mt_hdr_create INTO DATA(ls_hdr).
*
*      IF ls_hdr-employee_id IS INITIAL.
*        APPEND VALUE #(
*          leaveid = ls_hdr-leave_id
*          %msg    = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text     = 'Employee ID is mandatory' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
*      ENDIF.
*
*      IF ls_hdr-start_date IS INITIAL.
*        APPEND VALUE #(
*          leaveid = ls_hdr-leave_id
*          %msg    = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text     = 'Start date is mandatory' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
*      ENDIF.
*
*      IF ls_hdr-end_date IS INITIAL.
*        APPEND VALUE #(
*          leaveid = ls_hdr-leave_id
*          %msg    = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text     = 'End date is mandatory' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
*      ENDIF.
*
*      IF ls_hdr-end_date < ls_hdr-start_date
*      AND ls_hdr-end_date IS NOT INITIAL
*      AND ls_hdr-start_date IS NOT INITIAL.
*        APPEND VALUE #(
*          leaveid = ls_hdr-leave_id
*          %msg    = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text     = 'End date cannot be before start date' )
*        ) TO reported-leaveheader.
*        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
*      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD save.
*    " Header
*    IF lcl_buffer=>mt_hdr_create IS NOT INITIAL.
*      INSERT zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_create.
*    ENDIF.
*    IF lcl_buffer=>mt_hdr_update IS NOT INITIAL.
*      MODIFY zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_update.
*    ENDIF.
*    IF lcl_buffer=>mt_hdr_delete IS NOT INITIAL.
*      DELETE zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_delete.
*    ENDIF.
*
*    " Items
*    IF lcl_buffer=>mt_itm_create IS NOT INITIAL.
*      INSERT zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_create.
*    ENDIF.
*    IF lcl_buffer=>mt_itm_update IS NOT INITIAL.
*      MODIFY zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_update.
*    ENDIF.
*    IF lcl_buffer=>mt_itm_delete IS NOT INITIAL.
*      DELETE zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_delete.
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD cleanup.
*    lcl_buffer=>clear( ).
*  ENDMETHOD.
*
*  METHOD cleanup_finalize.
*    lcl_buffer=>clear( ).
*  ENDMETHOD.
*
*ENDCLASS.

" ============================================================
" LOCAL TYPES TAB (zbp_cit_010_i.clas.locals_def.abap)
" ============================================================


" ============================================================
" LOCAL TYPES TAB
" ACTIVATE THIS TAB FIRST before Local Implementations
" ============================================================

CLASS lcl_buffer DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-DATA:
      mt_hdr_create TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
      mt_hdr_update TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
      mt_hdr_delete TYPE STANDARD TABLE OF zcit_010_hdr WITH DEFAULT KEY,
      mt_itm_create TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY,
      mt_itm_update TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY,
      mt_itm_delete TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY.
    CLASS-METHODS clear.
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.
  METHOD clear.
    CLEAR: mt_hdr_create, mt_hdr_update, mt_hdr_delete,
           mt_itm_create, mt_itm_update, mt_itm_delete.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_leaveheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR leaveheader RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE leaveheader.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE leaveheader.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE leaveheader.
    METHODS read FOR READ
      IMPORTING keys FOR READ leaveheader RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK leaveheader.
    METHODS rba_leaveitems FOR READ
      IMPORTING keys_rba FOR READ leaveheader\_leaveitems
      FULL result_requested RESULT result LINK association_links.
    METHODS cba_leaveitems FOR MODIFY
      IMPORTING entities_cba FOR CREATE leaveheader\_leaveitems.
*        METHODS markasgranted FOR MODIFY
*      IMPORTING keys FOR ACTION leaveheader~MarkAsGranted
*      RESULT result.
*
*    METHODS markasrejected FOR MODIFY
*      IMPORTING keys FOR ACTION leaveheader~MarkAsRejected
*      RESULT result.

ENDCLASS.


CLASS lhc_leaveitems DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE leaveitems.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE leaveitems.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE leaveitems.
    METHODS read FOR READ
      IMPORTING keys FOR READ leaveitems RESULT result.
    METHODS rba_header FOR READ
      IMPORTING keys_rba FOR READ leaveitems\_header
      FULL result_requested RESULT result LINK association_links.
ENDCLASS.


CLASS lsc_zcit_010_i DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.






" ============================================================
" LOCAL IMPLEMENTATIONS TAB
" ABAP Cloud 2025
"
" ROOT CAUSES OF RAISE_SHORTDUMP FIXED:
"  FIX 1: MOVE-CORRESPONDING entity->DB removed
"          Entity has RAP fields %cid/%control/%tky that do
"          not exist in DB table -> causes immediate dump
"          Solution: explicit field-by-field assignment
"
"  FIX 2: READ ENTITIES inside handler removed
"          Causes recursive call into same RAP framework
"          that is currently executing -> dump
"          Solution: SELECT directly from DB table
"
"  FIX 3: mapped-leaveheader populated in create
"          Without this follow-on ops (create items after
"          header) cannot link %cid to new key -> dump
"
"  FIX 4: mapped-leaveitems populated in cba_leaveitems
"          Same reason as FIX 3
"
"  FIX 5: get_global_authorizations added (empty = allowed)
"          BDEF has authorization master(global,instance)
"          Missing method -> CX_RAP_HANDLER_NOT_IMPLEMENTED
"
"  FIX 6: All DATA() inline vars moved outside nested loops
"          DATA() inside loop does not reset per iteration
"          -> stale values -> dump on 2nd+ record
" ============================================================

CLASS lhc_leaveheader IMPLEMENTATION.


  METHOD get_instance_authorizations.
    " Empty = all instance operations authorized
  ENDMETHOD.

  METHOD lock.
    " Total etag handles optimistic locking via framework
  ENDMETHOD.

" ================================================================
" CREATE
" ================================================================
  METHOD create.
    DATA ls_hdr TYPE zcit_010_hdr.
    DATA lv_ts  TYPE timestamp.
    DATA lv_exists TYPE zcit_010_hdr-leave_id.

    LOOP AT entities INTO DATA(ls_entity).
      CLEAR: ls_hdr, lv_ts, lv_exists.

      " Validate leave_id provided
      IF ls_entity-leaveid IS INITIAL.
        APPEND VALUE #(
          %cid = ls_entity-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Leave ID is mandatory' )
        ) TO reported-leaveheader.
        APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-leaveheader.
        CONTINUE.
      ENDIF.

      " Validate no duplicate
      SELECT SINGLE leave_id
        FROM zcit_010_hdr
        WHERE leave_id = @ls_entity-leaveid
        INTO @lv_exists.
      IF sy-subrc = 0.
        APPEND VALUE #(
          %cid = ls_entity-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Leave ID already exists' )
        ) TO reported-leaveheader.
        APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-leaveheader.
        CONTINUE.
      ENDIF.

      " FIX 1: Explicit field assignment - no MOVE-CORRESPONDING
      ls_hdr-client      = sy-mandt.
      ls_hdr-leave_id    = ls_entity-leaveid.
      ls_hdr-employee_id = ls_entity-employeeid.
      ls_hdr-leave_type  = ls_entity-leavetype.
      ls_hdr-start_date  = ls_entity-startdate.
      ls_hdr-end_date    = ls_entity-enddate.
      ls_hdr-status      = COND #( WHEN ls_entity-status IS INITIAL
                                    THEN 'Pending'
                                    ELSE ls_entity-status ).

      " ABAP Cloud 2025: cl_abap_context_info instead of sy-uname
      ls_hdr-local_created_by      = cl_abap_context_info=>get_user_alias( ).
      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD lv_ts.
      ls_hdr-local_created_at      = lv_ts.
      ls_hdr-local_last_changed_at = lv_ts.
      ls_hdr-last_changed_at       = lv_ts.

      APPEND ls_hdr TO lcl_buffer=>mt_hdr_create.

      " FIX 3: Populate mapped so framework links %cid to new key
      INSERT VALUE #(
        %cid    = ls_entity-%cid
        leaveid = ls_hdr-leave_id
      ) INTO TABLE mapped-leaveheader.

    ENDLOOP.
  ENDMETHOD.


" ================================================================
" UPDATE
" ================================================================
  METHOD update.
    DATA ls_hdr TYPE zcit_010_hdr.
    DATA lv_ts  TYPE timestamp.

    LOOP AT entities INTO DATA(ls_entity).
      CLEAR: ls_hdr, lv_ts.

      SELECT SINGLE *
        FROM zcit_010_hdr
        WHERE leave_id = @ls_entity-leaveid
        INTO @ls_hdr.

      IF sy-subrc <> 0.
        APPEND VALUE #( leaveid = ls_entity-leaveid ) TO failed-leaveheader.
        APPEND VALUE #(
          leaveid = ls_entity-leaveid
          %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = 'Leave header not found' )
        ) TO reported-leaveheader.
        CONTINUE.
      ENDIF.

      IF ls_entity-%control-employeeid = if_abap_behv=>mk-on.
        ls_hdr-employee_id = ls_entity-employeeid.
      ENDIF.
      IF ls_entity-%control-leavetype  = if_abap_behv=>mk-on.
        ls_hdr-leave_type  = ls_entity-leavetype.
      ENDIF.
      IF ls_entity-%control-startdate  = if_abap_behv=>mk-on.
        ls_hdr-start_date  = ls_entity-startdate.
      ENDIF.
      IF ls_entity-%control-enddate    = if_abap_behv=>mk-on.
        ls_hdr-end_date    = ls_entity-enddate.
      ENDIF.
      IF ls_entity-%control-status     = if_abap_behv=>mk-on.
        ls_hdr-status      = ls_entity-status.
      ENDIF.

      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD lv_ts.
      ls_hdr-local_last_changed_at = lv_ts.
      ls_hdr-last_changed_at       = lv_ts.

      APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.

    ENDLOOP.
  ENDMETHOD.


" ================================================================
" DELETE
" ================================================================
  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE zcit_010_hdr(
        client   = sy-mandt
        leave_id = ls_key-leaveid
      ) TO lcl_buffer=>mt_hdr_delete.
    ENDLOOP.
  ENDMETHOD.


" ================================================================
" READ
" FIX 2: SELECT from DB - never READ ENTITIES inside handler
" ================================================================
  METHOD read.
    CHECK keys IS NOT INITIAL.

    SELECT *
      FROM zcit_010_hdr
      FOR ALL ENTRIES IN @keys
      WHERE leave_id = @keys-leaveid
      INTO TABLE @DATA(lt_hdr).

    LOOP AT lt_hdr INTO DATA(ls_db).
      INSERT VALUE #(
        leaveid            = ls_db-leave_id
        employeeid         = ls_db-employee_id
        leavetype          = ls_db-leave_type
        startdate          = ls_db-start_date
        enddate            = ls_db-end_date
        status             = ls_db-status
        localcreatedby     = ls_db-local_created_by
        localcreatedat     = ls_db-local_created_at
        locallastchangedby = ls_db-local_last_changed_by
        locallastchangedat = ls_db-local_last_changed_at
        lastchangedat      = ls_db-last_changed_at
      ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.


" ================================================================
" READ BY ASSOCIATION Header -> Items
" ================================================================
  METHOD rba_leaveitems.
    DATA lt_itm TYPE STANDARD TABLE OF zcit_010_itm WITH DEFAULT KEY.

    LOOP AT keys_rba INTO DATA(ls_key).
      CLEAR lt_itm.

      SELECT *
        FROM zcit_010_itm
        WHERE leave_id = @ls_key-leaveid
        INTO TABLE @lt_itm.

      LOOP AT lt_itm INTO DATA(ls_itm).
        INSERT VALUE #(
          source-%key        = ls_key-%key
          target-leaveid     = ls_itm-leave_id
          target-leaveitemno = ls_itm-leave_item_no
        ) INTO TABLE association_links.

        IF result_requested = if_abap_behv=>mk-on.
          INSERT VALUE #(
            leaveid            = ls_itm-leave_id
            leaveitemno        = ls_itm-leave_item_no
            leavedate          = ls_itm-leave_date
            daytype            = ls_itm-day_type
            localcreatedby     = ls_itm-local_created_by
            localcreatedat     = ls_itm-local_created_at
            locallastchangedby = ls_itm-local_last_changed_by
            locallastchangedat = ls_itm-local_last_changed_at
            lastchangedat      = ls_itm-last_changed_at
          ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


" ================================================================
" CREATE BY ASSOCIATION Header -> Items
" FIX 1: No MOVE-CORRESPONDING
" FIX 4: mapped-leaveitems populated
" FIX 6: All vars declared outside loops
" ================================================================
  METHOD cba_leaveitems.
    DATA ls_itm   TYPE zcit_010_itm.
    DATA lv_max   TYPE zcit_010_itm-leave_item_no.
    DATA lv_ts    TYPE timestamp.

    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        CLEAR: ls_itm, lv_max, lv_ts.

        ls_itm-client   = sy-mandt.
        ls_itm-leave_id = ls_cba-leaveid.

        " Auto-number: init lv_max=0 prevents dump if table empty
        lv_max = 0.
        SELECT SINGLE MAX( leave_item_no )
          FROM zcit_010_itm
          WHERE leave_id = @ls_itm-leave_id
          INTO @lv_max.

        " Also check buffer for items added in same transaction
        LOOP AT lcl_buffer=>mt_itm_create INTO DATA(ls_buf)
             WHERE leave_id = ls_itm-leave_id.
          IF ls_buf-leave_item_no > lv_max.
            lv_max = ls_buf-leave_item_no.
          ENDIF.
        ENDLOOP.

        ls_itm-leave_item_no         = lv_max + 1.
        ls_itm-leave_date            = ls_target-leavedate.
        ls_itm-day_type              = ls_target-daytype.
        ls_itm-local_created_by      = cl_abap_context_info=>get_user_alias( ).
        ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
        GET TIME STAMP FIELD lv_ts.
        ls_itm-local_created_at      = lv_ts.
        ls_itm-local_last_changed_at = lv_ts.
        ls_itm-last_changed_at       = lv_ts.

        APPEND ls_itm TO lcl_buffer=>mt_itm_create.

        " FIX 4: populate mapped
        INSERT VALUE #(
          %cid        = ls_target-%cid
          leaveid     = ls_itm-leave_id
          leaveitemno = ls_itm-leave_item_no
        ) INTO TABLE mapped-leaveitems.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

*  METHOD markasgranted.
*
*    DATA ls_hdr TYPE zcit_010_hdr.
*    DATA lv_ts  TYPE timestamp.
*
*    LOOP AT keys INTO DATA(ls_key).
*
*      SELECT SINGLE *
*        FROM zcit_010_hdr
*        WHERE leave_id = @ls_key-leaveid
*        INTO @ls_hdr.
*
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.
*
*      ls_hdr-status = 'Granted'.
*
*      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_hdr-local_last_changed_at = lv_ts.
*      ls_hdr-last_changed_at       = lv_ts.
*
*      APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.
*
*      INSERT VALUE #(
*        leaveid = ls_hdr-leave_id
*      ) INTO TABLE result.
*
*    ENDLOOP.
*
*  ENDMETHOD.
*
*    METHOD markasrejected.
*
*    DATA ls_hdr TYPE zcit_010_hdr.
*    DATA lv_ts  TYPE timestamp.
*
*    LOOP AT keys INTO DATA(ls_key).
*
*      SELECT SINGLE *
*        FROM zcit_010_hdr
*        WHERE leave_id = @ls_key-leaveid
*        INTO @ls_hdr.
*
*      IF sy-subrc <> 0.
*        CONTINUE.
*      ENDIF.
*
*      ls_hdr-status = 'Rejected'.
*
*      ls_hdr-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
*      GET TIME STAMP FIELD lv_ts.
*      ls_hdr-local_last_changed_at = lv_ts.
*      ls_hdr-last_changed_at       = lv_ts.
*
*      APPEND ls_hdr TO lcl_buffer=>mt_hdr_update.
*
*      INSERT VALUE #(
*        leaveid = ls_hdr-leave_id
*      ) INTO TABLE result.
*
*    ENDLOOP.
*
*  ENDMETHOD.


ENDCLASS.


" ============================================================
" ITEM HANDLER
" ============================================================
CLASS lhc_leaveitems IMPLEMENTATION.

  METHOD create.
    DATA ls_itm TYPE zcit_010_itm.
    DATA lv_max TYPE zcit_010_itm-leave_item_no.
    DATA lv_ts  TYPE timestamp.

    LOOP AT entities INTO DATA(ls_entity).
      CLEAR: ls_itm, lv_max, lv_ts.

      ls_itm-client   = sy-mandt.
      ls_itm-leave_id = ls_entity-leaveid.

      lv_max = 0.
      SELECT SINGLE MAX( leave_item_no )
        FROM zcit_010_itm
        WHERE leave_id = @ls_itm-leave_id
        INTO @lv_max.

      LOOP AT lcl_buffer=>mt_itm_create INTO DATA(ls_buf)
           WHERE leave_id = ls_itm-leave_id.
        IF ls_buf-leave_item_no > lv_max.
          lv_max = ls_buf-leave_item_no.
        ENDIF.
      ENDLOOP.

      ls_itm-leave_item_no         = lv_max + 1.
      ls_itm-leave_date            = ls_entity-leavedate.
      ls_itm-day_type              = ls_entity-daytype.
      ls_itm-local_created_by      = cl_abap_context_info=>get_user_alias( ).
      ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD lv_ts.
      ls_itm-local_created_at      = lv_ts.
      ls_itm-local_last_changed_at = lv_ts.
      ls_itm-last_changed_at       = lv_ts.

      APPEND ls_itm TO lcl_buffer=>mt_itm_create.

      INSERT VALUE #(
        %cid        = ls_entity-%cid
        leaveid     = ls_itm-leave_id
        leaveitemno = ls_itm-leave_item_no
      ) INTO TABLE mapped-leaveitems.

    ENDLOOP.
  ENDMETHOD.


  METHOD update.
    DATA ls_itm TYPE zcit_010_itm.
    DATA lv_ts  TYPE timestamp.

    LOOP AT entities INTO DATA(ls_entity).
      CLEAR: ls_itm, lv_ts.

      SELECT SINGLE *
        FROM zcit_010_itm
        WHERE leave_id      = @ls_entity-leaveid
          AND leave_item_no = @ls_entity-leaveitemno
        INTO @ls_itm.

      IF sy-subrc <> 0.
        APPEND VALUE #(
          leaveid     = ls_entity-leaveid
          leaveitemno = ls_entity-leaveitemno
        ) TO failed-leaveitems.
        APPEND VALUE #(
          leaveid     = ls_entity-leaveid
          leaveitemno = ls_entity-leaveitemno
          %msg        = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Leave item not found' )
        ) TO reported-leaveitems.
        CONTINUE.
      ENDIF.

      IF ls_entity-%control-leavedate = if_abap_behv=>mk-on.
        ls_itm-leave_date = ls_entity-leavedate.
      ENDIF.
      IF ls_entity-%control-daytype   = if_abap_behv=>mk-on.
        ls_itm-day_type   = ls_entity-daytype.
      ENDIF.

      ls_itm-local_last_changed_by = cl_abap_context_info=>get_user_alias( ).
      GET TIME STAMP FIELD lv_ts.
      ls_itm-local_last_changed_at = lv_ts.
      ls_itm-last_changed_at       = lv_ts.

      APPEND ls_itm TO lcl_buffer=>mt_itm_update.

    ENDLOOP.
  ENDMETHOD.


  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE zcit_010_itm(
        client        = sy-mandt
        leave_id      = ls_key-leaveid
        leave_item_no = ls_key-leaveitemno
      ) TO lcl_buffer=>mt_itm_delete.
    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    CHECK keys IS NOT INITIAL.

    SELECT *
      FROM zcit_010_itm
      FOR ALL ENTRIES IN @keys
      WHERE leave_id      = @keys-leaveid
        AND leave_item_no = @keys-leaveitemno
      INTO TABLE @DATA(lt_itm).

    LOOP AT lt_itm INTO DATA(ls_db).
      INSERT VALUE #(
        leaveid            = ls_db-leave_id
        leaveitemno        = ls_db-leave_item_no
        leavedate          = ls_db-leave_date
        daytype            = ls_db-day_type
        localcreatedby     = ls_db-local_created_by
        localcreatedat     = ls_db-local_created_at
        locallastchangedby = ls_db-local_last_changed_by
        locallastchangedat = ls_db-local_last_changed_at
        lastchangedat      = ls_db-last_changed_at
      ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.


  METHOD rba_header.
    CHECK keys_rba IS NOT INITIAL.

    SELECT *
      FROM zcit_010_itm
      FOR ALL ENTRIES IN @keys_rba
      WHERE leave_id      = @keys_rba-leaveid
        AND leave_item_no = @keys_rba-leaveitemno
      INTO TABLE @DATA(lt_itm).

    LOOP AT lt_itm INTO DATA(ls_itm).
      CHECK ls_itm-leave_id IS NOT INITIAL.

      READ TABLE keys_rba INTO DATA(ls_key)
           WITH KEY leaveid     = ls_itm-leave_id
                    leaveitemno = ls_itm-leave_item_no.

      INSERT VALUE #(
        source-%key    = ls_key-%key
        target-leaveid = ls_itm-leave_id
      ) INTO TABLE association_links.

      IF result_requested = if_abap_behv=>mk-on.
        SELECT SINGLE *
          FROM zcit_010_hdr
          WHERE leave_id = @ls_itm-leave_id
          INTO @DATA(ls_hdr).

        IF sy-subrc = 0.
          INSERT VALUE #(
            leaveid            = ls_hdr-leave_id
            employeeid         = ls_hdr-employee_id
            leavetype          = ls_hdr-leave_type
            startdate          = ls_hdr-start_date
            enddate            = ls_hdr-end_date
            status             = ls_hdr-status
            localcreatedby     = ls_hdr-local_created_by
            localcreatedat     = ls_hdr-local_created_at
            locallastchangedby = ls_hdr-local_last_changed_by
            locallastchangedat = ls_hdr-local_last_changed_at
            lastchangedat      = ls_hdr-last_changed_at
          ) INTO TABLE result.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


" ============================================================
" SAVER
" ============================================================
CLASS lsc_zcit_010_i IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
    LOOP AT lcl_buffer=>mt_hdr_create INTO DATA(ls_hdr).
      IF ls_hdr-employee_id IS INITIAL.
        APPEND VALUE #(
          leaveid = ls_hdr-leave_id
          %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = 'Employee ID is mandatory' )
        ) TO reported-leaveheader.
        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
      ENDIF.
      IF ls_hdr-start_date IS INITIAL.
        APPEND VALUE #(
          leaveid = ls_hdr-leave_id
          %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = 'Start date is mandatory' )
        ) TO reported-leaveheader.
        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
      ENDIF.
      IF ls_hdr-end_date IS INITIAL.
        APPEND VALUE #(
          leaveid = ls_hdr-leave_id
          %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = 'End date is mandatory' )
        ) TO reported-leaveheader.
        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
      ENDIF.
      IF ls_hdr-end_date < ls_hdr-start_date
      AND ls_hdr-end_date IS NOT INITIAL
      AND ls_hdr-start_date IS NOT INITIAL.
        APPEND VALUE #(
          leaveid = ls_hdr-leave_id
          %msg    = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text     = 'End date cannot be before start date' )
        ) TO reported-leaveheader.
        APPEND VALUE #( leaveid = ls_hdr-leave_id ) TO failed-leaveheader.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD save.
    IF lcl_buffer=>mt_hdr_create IS NOT INITIAL.
      INSERT zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_create.
    ENDIF.
    IF lcl_buffer=>mt_hdr_update IS NOT INITIAL.
      MODIFY zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_update.
    ENDIF.
    IF lcl_buffer=>mt_hdr_delete IS NOT INITIAL.
      DELETE zcit_010_hdr FROM TABLE @lcl_buffer=>mt_hdr_delete.
    ENDIF.
    IF lcl_buffer=>mt_itm_create IS NOT INITIAL.
      INSERT zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_create.
    ENDIF.
    IF lcl_buffer=>mt_itm_update IS NOT INITIAL.
      MODIFY zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_update.
    ENDIF.
    IF lcl_buffer=>mt_itm_delete IS NOT INITIAL.
      DELETE zcit_010_itm FROM TABLE @lcl_buffer=>mt_itm_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    lcl_buffer=>clear( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    lcl_buffer=>clear( ).
  ENDMETHOD.

ENDCLASS.
