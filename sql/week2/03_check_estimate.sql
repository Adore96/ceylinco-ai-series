-- =====================================================================
-- Week 2 / 03_check_estimate.sql: SQL checks decide, not the model
-- =====================================================================
-- ANCHOR: "Trust the checks, not the model's opinion of itself."
--
-- WHY: the model reads the paper. Four plain SQL checks decide whether
--   the estimate can become a claim on its own (AUTO_OK) or needs a
--   person (NEEDS_REVIEW). Any failed check sends it to review.
--
-- THE CHECKS (each one is a query you could write without AI):
--   1. required_fields     it is a garage estimate with reg_no, garage,
--                          total and at least one line item.
--   2. items_add_up        SUM of line amounts (JSON_TABLE) = written total.
--   3. active_motor_policy the vehicle belongs to an ACTIVE motor policy.
--                          Registration numbers are compared without
--                          spaces or hyphens: "WP CAB-4521" = "WPCAB4521".
--   4. model_confident     model_score >= 0.80. Only one vote of four.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- EXPECTED: "Procedure created."
-- THEN TEST: begin check_estimate( <estimate_id> ); end;
--   then: select estimate_id, review_status, json_serialize( check_results pretty )
--           from estimates where estimate_id = <estimate_id>;
--
-- Docs checked (21 Nov 2026), Oracle AI Database 26ai JSON Developer's
--   Guide: JSON_TABLE (NESTED PATH not needed: line_items is one array),
--   JSON_VALUE, JSON_OBJECT, JSON data type.
-- =====================================================================
create or replace procedure check_estimate ( p_estimate_id in number )
is
    c_min_score constant number := 0.80;
    l_required  number;
    l_add_up    number;
    l_policy    number;
    l_score_ok  number;
begin
    -- 1. Required fields.
    select case when json_value( e.extracted_json, '$.document_type' ) = 'GARAGE_ESTIMATE'
                 and json_value( e.extracted_json, '$.reg_no' )      is not null
                 and json_value( e.extracted_json, '$.garage_name' ) is not null
                 and json_value( e.extracted_json, '$.total_lkr' returning number ) is not null
                 and json_exists( e.extracted_json, '$.line_items[0]' )
                then 1 else 0 end,
           case when e.model_score >= c_min_score then 1 else 0 end
      into l_required, l_score_ok
      from estimates e
     where e.estimate_id = p_estimate_id;

    -- 2. Line items add up to the written total (to the rupee).
    select case when abs( nvl( sum( li.amount_lkr ), -1 )
                        - max( json_value( e.extracted_json, '$.total_lkr' returning number ) ) ) < 1
                then 1 else 0 end
      into l_add_up
      from estimates e,
           json_table( e.extracted_json, '$.line_items[*]'
                       columns ( amount_lkr number path '$.amount_lkr' ) ) li
     where e.estimate_id = p_estimate_id;

    -- 3. The vehicle is on an ACTIVE motor policy.
    select count(*)
      into l_policy
      from estimates e
      join vehicles  v on upper( regexp_replace( v.reg_no, '[ -]', '' ) )
                        = upper( regexp_replace( json_value( e.extracted_json, '$.reg_no' ), '[ -]', '' ) )
      join policies  p on p.policy_id = v.policy_id
     where e.estimate_id = p_estimate_id
       and p.policy_type = 'MOTOR'
       and p.status      = 'ACTIVE';

    update estimates
       set check_results = json_object(
               'required_fields'     value case l_required when 1 then 'true' else 'false' end format json,
               'items_add_up'        value case l_add_up   when 1 then 'true' else 'false' end format json,
               'active_motor_policy' value case when l_policy > 0 then 'true' else 'false' end format json,
               'model_confident'     value case l_score_ok when 1 then 'true' else 'false' end format json ),
           review_status = case when l_required = 1 and l_add_up = 1 and l_policy > 0 and l_score_ok = 1
                                then 'AUTO_OK' else 'NEEDS_REVIEW' end
     where estimate_id = p_estimate_id;
end check_estimate;
/
