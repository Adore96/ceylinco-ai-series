-- =====================================================================
-- S5: Can we publish a PL/SQL-backed GET endpoint and open it in a browser?
-- =====================================================================
-- WHY: in Week 3 the policy and claim lookups are agent tools AND REST
--      endpoints ("the API and the tool are the same code"). The endpoint
--      is for show only. Fallback: a slide.
--
-- IMPORTANT CHANGE IN APEX 26.2: the RESTful Services pages in SQL
--   Workshop ("REST Workshop") were removed. Authoring moved to SQL
--   Developer Web. So this spike uses the ORDS PL/SQL API instead of
--   clicks. The API belongs to ORDS, not APEX, so the removal does not
--   touch it. A script is also easier to repeat on the day.
--
-- NEEDS: table SPIKE_POLICIES (S7.sql STEP 1). Run that first.
--
-- HOW TO RUN: SQL Workshop > SQL Commands, one step at a time.
--
-- Docs checked (19 Nov 2026):
--   Oracle APEX blog "Oracle APEX 26.2: Developer and administration
--   updates": REST Workshop removed in 26.2, existing ORDS modules stay.
--   ORDS 25.2 Developer's Guide, ORDS PL/SQL Package Reference:
--   ORDS.ENABLE_SCHEMA ("Any user can enable or disable their own
--   schema"), ORDS.DEFINE_SERVICE, ORDS.DELETE_MODULE,
--   source_type_collection_item (one row as ORDS standard JSON).
-- UNVERIFIED: which ORDS version oracleapex.com runs, and whether the
--   USER_ORDS_SCHEMAS view is visible to your schema.
-- =====================================================================


-- ---------------------------------------------------------------------
-- STEP 1: is the schema already REST-enabled?
-- Expected: one row. PATTERN is the alias used in the URL.
--   Write the PATTERN value down (do NOT commit it to the repo).
-- If no rows: run STEP 1B. If an error says the view does not exist,
--   copy the error into the chat.
-- ---------------------------------------------------------------------
select * from user_ords_schemas;


-- ---------------------------------------------------------------------
-- STEP 1B (only if STEP 1 returned no rows): REST-enable your own schema.
-- Expected: "Statement processed." Then run STEP 1 again.
-- ---------------------------------------------------------------------
begin
    ords.enable_schema( p_enabled => true );
    commit;
end;
/


-- ---------------------------------------------------------------------
-- STEP 2: one module, one URL template, one GET handler, in one call.
-- WHY collection_item: one policy number returns one JSON object,
--   which is what a call-centre lookup needs.
-- WHY :policy_no: the URL segment becomes a bind variable, so the query
--   is safe from SQL injection.
-- Expected: "Statement processed."
-- ---------------------------------------------------------------------
begin
    ords.define_service (
        p_module_name => 'spike',
        p_base_path   => 'spike/',
        p_pattern     => 'policies/:policy_no',
        p_method      => 'GET',
        p_source_type => ords.source_type_collection_item,
        p_source      => 'select policy_no, holder_name, policy_type, status, premium_lkr, next_due_date
                            from spike_policies
                           where policy_no = :policy_no' );
    commit;
end;
/


-- ---------------------------------------------------------------------
-- STEP 3: open this URL in a browser tab (replace <PATTERN>):
--   https://oracleapex.com/ords/<PATTERN>/spike/policies/LSM-20015
-- Expected: JSON like
--   {"policy_no":"LSM-20015","holder_name":"Nuwan Bandara",
--    "policy_type":"MOTOR","status":"ACTIVE","premium_lkr":58900, ...}
-- PASS: you see that JSON.
-- FAIL: 404 or an error page. Copy the page text into the chat.
-- UNVERIFIED: the host part of the URL. If it differs, copy the host
--   from your browser address bar while you are in APEX.
-- ---------------------------------------------------------------------
