-- =====================================================================
-- S1: Can APEX_AI.GENERATE send an image to the "claude" service?
-- =====================================================================
-- WHY: Week 2 (Case 1) reads garage estimate images. If APEX_AI can send
--      an image attachment, the whole extraction runs inside APEX.
--      If not, the fallback is a direct call to the Anthropic Messages API
--      with APEX_WEB_SERVICE (same web credential, base64 image).
--
-- HOW TO RUN: SQL Workshop > SQL Commands. Paste this whole block. Click Run.
--
-- WHAT IT DOES:
--   1. Turns a tiny base64 PNG (340 x 90 px, 779 bytes) into a BLOB.
--      No table and no upload needed: the image lives in this script.
--      The image shows two lines of text:
--        SPIKE TEST MOTORS - ESTIMATE
--        TOTAL: LKR 12,500.00
--   2. Sends the BLOB as an attachment with a short prompt.
--   3. Prints the BLOB size and the model's answer.
--
-- EXPECTED OUTPUT (DBMS Output pane), roughly:
--   Image bytes: 779
--   Answer: Garage: SPIKE TEST MOTORS, Total: LKR 12,500.00
--   Seconds: (a small number)
--
-- PASS: the answer names SPIKE TEST MOTORS and 12,500.
-- FAIL: an error, or an answer that says it cannot see an image.
--       Copy the full error text into the chat.
--
-- Docs checked (19 Nov 2026):
--   APEX_AI.GENERATE Signature 2, APEX 26.2 API Reference
--   (p_attachments IN t_attachments)
--   APEX_AI Data Types, APEX 26.2 (t_attachment: mime_type, content_blob,
--   content_clob, file_name, detail_level)
--   APEX_WEB_SERVICE.CLOBBASE642BLOB, APEX API Reference
-- UNVERIFIED: the docs do not list which providers accept images.
--   That is exactly what this spike tests for Anthropic.
-- =====================================================================
declare
    -- WHY a base64 literal: it is the shortest way to get a real image
    -- into a BLOB from SQL Commands, with nothing to upload.
    l_base64 clob :=
        'iVBORw0KGgoAAAANSUhEUgAAAVQAAABaAQAAAADPlJPcAAAC0klEQVR42u2VvW4bRxSFvyEJcRDQ1iIQYBkwrI2fgOmSQNEO/AR+hFWVIo3VyYZMXv0UKVykDGBByy5lXCRVYHJlB0GqiEWKVPLQjVgYyCoU4hVD7k0h0kAiKnDpgqec+XDm3HsHM0Z5V52WeHfN2Tn7b/Y8st1oPTyslk43SurCvV7l+TjoAeb0gTlyYWI+DiZs3h0GawKQtUB5BB05'
     || '8+5iIVCyqW+FQfdJ9uxLr/n2yXdA8yDZOrid7TuITr4N/0C+fjOqTXwroQSfWQoR62Ji7nbSj3oEAs66p0FM/royzRsg2fc5JZGQFu1i20SuiQNSuJe11S2NpuyQzaB/HsLOGbABgKEPHC5BsEHAeFpbNfwwAwrhmovZB03RpZsCXHNPs322Xr/tWfV+pbtc9SVpLPoWAsYBt9Me0aK/d10KlsrZdBbxZn3VAkIqPLyw8EYMjjT98yFBNqkN1Z/1+NMT'
     || 'HTWamiTF4KDRiKLPBxqpRpocHQ++MYOBqqpmJbJf5DSylBripcVj2sa91IUO4LwE2WOTV976+uv6ci1eKQqTrnQKTSia8uBcIlXSleRAn4xO/OLEd7kumUsphHrsEV6YdH23HKdAPa7XJad20TLM/I2as3N2zr7X7KHd61W6fWj1jyw/ncvYvho7glczfR9BbiG03SFpvwXJmR/nyQx27c1qstXNweetTeo3hPxWWfC3ZrCF3O2kIwth1QnO1g139uqm'
     || 'dkcus6XGtnGtfIj/SwToaigZI+SqPlgL4Xiy3zeEWDMzA5qu5Qt4+ABoGa94cp3BlgQTYSEsA6gr1f5/Fl/l4K3ch0KunEWFYoeorRbCv9MfYVwG+YHKMO7NytA2bvQ7eOt3Ycjot2Pp6tmMA7RQiq0ivqnyxa8jlXjxk6pkK6tV0f8oq1DsvjDPdgBsvmMMLCyv10Ls+uXAeklNna3s8p28+nOc/5tzds6+n+w/TrmAy/B66FYAAAAASUVORK5CYII=';

    l_image    blob;
    l_answer   clob;
    l_start    timestamp := systimestamp;
begin
    -- Base64 text -> binary PNG.
    l_image := apex_web_service.clobbase642blob( l_base64 );
    sys.dbms_output.put_line( 'Image bytes: ' || dbms_lob.getlength( l_image ) );

    l_answer := apex_ai.generate (
        p_service_static_id => 'claude',
        p_prompt            => 'Read the attached image. Reply in one line: '
                            || 'Garage: <name>, Total: <amount with currency>.',
        -- WHY a collection: one call can carry several files (Week 2 sends one).
        p_attachments       => apex_ai.t_attachments (
                                   apex_ai.t_attachment (
                                       mime_type    => 'image/png',
                                       content_blob => l_image,
                                       file_name    => 's1-test.png' ) ) );

    sys.dbms_output.put_line( 'Answer: ' || l_answer );
    sys.dbms_output.put_line( 'Seconds: ' ||
        round( extract( second from ( systimestamp - l_start ) ), 1 ) );
end;
/
