-- =====================================================================
-- Week 2 / 04_create_claim.sql: turn a checked estimate into a claim
-- =====================================================================
-- ANCHOR: "Only checked data becomes a claim." (Case 1, step 6)
--
-- WHY a gate: a claim is created only from an estimate that passed every
--   SQL check (AUTO_OK) or that a person approved (APPROVED). Anything
--   else raises an error, so no page or task can skip the review.
--
-- WHAT IT DOES:
--   1. Finds the vehicle and its policy from the reg number the AI read
--      (spaces and hyphens ignored, same rule as 03_check_estimate).
--   2. Takes the next claim number, CLM-26-0011 onwards (the seed data
--      has 0001 to 0010). Week 3 callers ask about 0011 to 0013.
--   3. Inserts the claim (status OPEN, amount = the estimate total,
--      incident date = the estimate date) and links both rows.
--   Calling it twice for one estimate returns the existing claim number.
--
-- WHY the amount is the WRITTEN total for an approved estimate: the
--   reviewer approved the paper as it is. Correcting the amount is a
--   claims-handling step, not an AI step.
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste. Run.
-- EXPECTED: "Function created."
-- THEN TEST: begin dbms_output.put_line( create_claim( <estimate_id> ) ); end;
--   (a function that inserts cannot be called from a SELECT)
--
-- Docs checked (22 Nov 2026), Oracle AI Database 26ai: JSON_VALUE,
--   REGEXP_REPLACE, RETURNING INTO, SELECT ... FOR UPDATE.
-- =====================================================================
create or replace function create_claim ( p_estimate_id in number ) return varchar2
is
    l_status     estimates.review_status%type;
    l_claim_id   estimates.claim_id%type;
    l_json       estimates.extracted_json%type;
    l_vehicle_id vehicles.vehicle_id%type;
    l_policy_id  policies.policy_id%type;
    l_claim_no   claims.claim_no%type;
begin
    -- FOR UPDATE: two clicks on the same estimate cannot make two claims.
    select review_status, claim_id, extracted_json
      into l_status, l_claim_id, l_json
      from estimates
     where estimate_id = p_estimate_id
       for update;

    if l_claim_id is not null then
        select claim_no into l_claim_no from claims where claim_id = l_claim_id;
        return l_claim_no;
    end if;

    if l_status not in ( 'AUTO_OK', 'APPROVED' ) or l_status is null then
        raise_application_error( -20001,
            'Estimate ' || p_estimate_id || ' is ' || nvl( l_status, 'not checked' )
            || '. Only AUTO_OK or APPROVED estimates become claims.' );
    end if;

    select v.vehicle_id, v.policy_id
      into l_vehicle_id, l_policy_id
      from vehicles v
     where upper( regexp_replace( v.reg_no, '[ -]', '' ) )
         = upper( regexp_replace( json_value( l_json, '$.reg_no' ), '[ -]', '' ) );

    -- WHY max + 1 and not a sequence: claim numbers are business numbers
    -- that continue the seeded series. FOR UPDATE above serialises calls
    -- per estimate; a real system would use a sequence.
    select 'CLM-26-' || to_char( nvl( max( to_number( substr( claim_no, 8 ) ) ), 0 ) + 1, 'fm0000' )
      into l_claim_no
      from claims
     where claim_no like 'CLM-26-%';

    insert into claims ( claim_no, policy_id, vehicle_id, incident_date, claim_type, status, amount_lkr, estimate_id )
    values ( l_claim_no, l_policy_id, l_vehicle_id,
             nvl( to_date( json_value( l_json, '$.estimate_date' ), 'YYYY-MM-DD' ), trunc( sysdate ) ),
             'ACCIDENT', 'OPEN',
             json_value( l_json, '$.total_lkr' returning number ),
             p_estimate_id )
    returning claim_id into l_claim_id;

    update estimates set claim_id = l_claim_id where estimate_id = p_estimate_id;
    return l_claim_no;
end create_claim;
/
