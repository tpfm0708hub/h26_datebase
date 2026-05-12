--학생수강 테이블
----1.[AFTER INSERT]: 존재하지 않는 학번 차단
CREATE OR REPLACE TRIGGER trg_check_student_exists
    AFTER INSERT ON 수강
FOR EACH ROW
    DECLARE
        v_cnt   NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt
            FROM 학생 s
        WHERE s.학번 = :NEW.학번;
    IF v_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '존재하지 않는 학번입니다.');
    END IF;
END;
/
----2[BEFORE INSERT]: 중복 수강 차단
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_enroll
    BEFORE INSERT ON 수강
FOR EACH ROW
    DECLARE
        v_cnt   NUMBER;
    BEGIN
        SELECT COUNT(*) 
            INTO v_cnt
        FROM 수강 r
            WHERE r.학번 = :NEW.학번 AND r.과목코드 = :NEW.과목코드;

    IF v_cnt > 0 THEN
----3 [AFTER INSERT] 수강 신청 이력 기록
CREATE OR REPLACE TRIGGER trg_log_enroll_history
    AFTER INSERT ON 수강
FOR EACH ROW
    BEGIN
        INSERT INTO 수강신청이력(학번, 과목코드, 수강학기, 신청일시)
        VALUES (:NEW.학번, :NEW.과목코드, :NEW.수강학기, SYSDATE);
    END;
/
----4 [BEFORE INSERT] 학년 범위 제한
CREATE OR REPLACE TRIGGER trg_check_grade_range
    BEFORE INSERT ON 학생
FOR EACH ROW
    BEGIN
        IF :new.학년 < 1 OR :new.학년 > 4 THEN
            RAISE_APPLICATION_ERROR(-20003, '1학년과 4학년 사이만 입력하세요.')
        END IF;
    END;
/
----5 [AFTER UPDATE] 성적 변경 이력 기록
CREATE OR REPLACE TRIGGER trg_log_score_change
    AFTER UPDATE OF 성적 ON 수강
FOR EACH ROW
    BEGIN
        INSERT INTO 성적변경이력(학번, 과목코드, 이전성적, 변경성적, 변경일시)
        VALUES (:old.학번, :old.과목코드, :old.성적, :new.성적, SYSDATE);
    END;
/
----6. [BEFORE UPDATE] 성적 유효 범위 검사
CREATE OR REPLACE TRIGGER trg_validate_score
    BEFORE UPDATE OF 성적 ON 수강
FOR EACH ROW
    BEGIN
        IF :new.성적 < 0 OR :new.성적 > 100 THEN
            RAISE_APPLICATION_ERROR(-20004, '성적은 0에서 100 사이를 입력 바랍니다.');
        END IF;
    END;
/
----7. [AFTER UPDATE] 전공 변경 이력 기록
CREATE OR REPLACE trg_log_major_change
    AFTER UPDATE OF 전공 ON 학생
FOR EACH ROW
    BEGIN
        INSERT INTO 전공변경이력(학번, 이름, 이전전공, 변경전공, 변경일시)
        VALUES (:old.학번, :old.이름, :old.전공, :new.전공, SYSDATE)
    END;
/
----8. [AFTER UPDATE] 미이수 경고 출력
CREATE OR REPLACE TRIGGER trg_warn_fail
    AFTER UPDATE OF 성적 ON 수강
FOR EACH ROW
    BEGIN
        IF :new.성적 < 60 THEN
            DBMS_OUTPUT.PUT_LINE('미이수 경고: 학번 = ' || :new.학번 ||
                                 ', 과목코드 = ' || new.과목코드);
        END IF;
    END;
/
----9. [BEFORE DELETE] 학생 삭제 시 관련 수강 자동 삭제
CREATE OR REPLACE TRIGGER trg_cascade_delete_stud
    BEFORE DELETE ON 학생
FOR EACH ROW
    BEGIN
        DELETE FROM 수강 WHERE 학번 = :old.학번;
    END;
/
----10. [BEFORE DELETE] 과목 삭제 시 백업 및 수강 삭제
CREATE OR REPLACE TRIGGER trg_backup_and_delete_sub
    BEFORE DELETE ON 과목
FOR EACH ROW
    BEGIN
        INSERT INTO 삭제과목이력(과목코드, 과목이름, 담당교수, 삭제일시)
        VALUES(:old.과목코드, :old.과목일므, :old.담당교수, SYSDATE);

        DELETE FROM 수강 WHERE 과목코드 = :old.과목코드;
    END;
/

--마당서점 DB기준 트리거
----1. [BEFORE INSERT] 존재하지 않는 고객 차단
CREATE OR REPLACE TRIGGER trg_check_customer
    BEFORE INSERT ON Orders
FOR EACH ROW
    DECLARE
        v_cnt   NUMBER;
    BEGIN  
        SELECT COUNT(*) 
            INTO v_cnt 
        FROM Customer c
            WHERE c.custid = :new.custid;
    IF v_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '등록되지 않은 고객번호입니다.');
    END IF;
END;
/
----2.[BEFORE INSERT]
CREATE OR REPLACE TRIGGER trg_check_book
    BEFORE INSERT ON Orders
FOR EACH ROW
    DECLARE
        v_cnt_NUMBER;
    BEGIN
        SELECT COUNT(*)
            INTO v_cnt
        FROM Book b
            WHERE b.bookid = :new.bookid;
    IF v_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '존재하지 않는 도서번호입니다.');
    END IF;
END;
/
----3. [BEFORE INSERT] 판매가격 유효성 검사
CREATE OR REPLACE TRIGGER trg_check_saleprice
    BEFORE INSERT ON Orders
FOR EACH ROW
    BEGIN
        IF :new.saleprice < 0 THEN
            RAISE_APPLICATION_ERROR(-20003, '판매가격이 0보다 작을 수 없습니다.')
        END IF;
    END;
/
----4. [AFTER INSERT] 주문 정보 자동 백업
CREATE OR REPLACE TRIGGER trg_backup_order
    AFTER INSERT ON Orders
FOR EACH ROW
    BEGIN
        INSERT INTO 주문이력(orderid, custid, bookid, saleprice, orderdate, 기록일시)
    VALUES (:new.orderid, :new.custid, :new.bookid, :new.saleprice, :new.orderdate, SYSDATE);
END;
/
----5. [BEFORE UPDATE] 도서 가격 급등 차단
CREATE OR REPLACE TRIGGER trg_limit_price_increase
    BEFORE UPDATE OF price ON Book
FOR EACH ROW
    BEGIN
        IF :new.price > :old.price * 1.5 THEN
            RAISE_APPLICATION_ERROR(-20004, '가격 인상폭이 너무 큽니다.')
        END IF;
    END;
/
----6. [AFTER UPDATE] 판매가 변경 및 차액 기록
CREATE OR REPLACE TRIGGER trg_log_saleprice_diff
    AFTER UPDATE OF saleprice ON Orders
FOR EACH ROW
    BEGIN
        INSERT INTO saleprice_log(orderid, before_price, after_price, diff, chg_date)
        VALUE(:old.orderid, :old.saleprice, :new.saleprice, (:new.saleprice - :old.saleprice), SYSDATE);
    END;
/
----7. [AFTER UPDATE] 연락처 변경 이력 관리
CREATE OR REPLACE TRIGGER trg_log_phone_change
    AFTER UPDATE OF phone ON Customer
FOR EACH ROW
    BEGIN
        INSERT INTO phone_change_log(custid, name, old_phone, new_phone, chg_date)
        VALUES(:old.custid, :old.name, :old.phone, :new.phone, SYSDATE);
    END;
/
----8. [BEFORE DELETE] 고객 삭제 시 주문 내역 동시 삭제
CREATE OR REPLACE TRIGGER trg_cascade_customer_del
    BEFORE DELETE ON Customer
FOR EACH ROW
    BEGIN
        DELETE FROM Orders o WHERE o.custid = :old.custid;
    END;
/
----9. [BEFORE DELETE] 도서 삭제 시 백업 및 주문 삭제
CREATE OR REPLACE TRIGGER trg_book_backup_del
    BEFORE DELETE ON Book
FOR EACH ROW
    BEGIN
        INSERT INTO delete_book_log(bookid, bookname, publisher, price, 삭제일시)
        VALUES (:old.bookid, old:bookname, old:publisher, old:price, SYSDATE);

        DELETE FROM Orders o WHERE o.bookid = :old.bookid;
    END;
/
----10. [BEFORE INSERT] 중복 주문 방지
CREATE OR REPLACE TRIGGER trg_precent_duplicate_order
    BEFORE INSERT ON Orders
FOR EACH ROW
    DECLARE
        v_cnt   NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt
            FROM Orders o
        WHERE o.custid = :new.custid
          AND o.bookid = :new.bookid
          AND TRUNC(orderdate) = TRUNC(:new.orderdate);

        IF v_cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, '이미 같은 날짜에 해당 도서를 주문했습니다.')
        END IF;
    END;
/
--극장 DB기준 트리거
----1.[BEFORE INSERT]
CREATE OR REPLACE TRIGGER trg_check_res_cust
    BEFORE INSERT ON 예약
FOR EACH ROW
    DECLARE
        v_cnt   NUMBERl
    BEGIN
        SELECT COUNT(*)
            INTO v_cnt
        FROM 고객 c
            WHERE c.고객번호 = :new.고객번호;
        IF v_cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, '등록되지 않은 고객번호입니다.');
        END IF;
    EMD;
/
----2. [BEFORE INSERT] 중복 좌석 예약 차단
CREATE OR REPLACE TRIGGER trg_prevent_double_booking
    BEFORE INSERT ON 예약
FOR EACH ROW
    DECLARE v_cnt   NUMBER;
    BEGIN
        SELECT COUNT(*)
            INTO v_cnt
        FROM 예약 r
            WHERE r.극장번호 = :new.극장번호 AND r.상영관번호 = :new.상영관번호 AND
                  r.날짜 = :new.날짜 AND r.좌석번호 = :new.좌석번호;
        If v_cnt > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, '이미 예약된 좌석입니다.');
        END IF;
    END;
/
----3. [BEFORE INSERT] 매진 시 예약 차단
CREATE OR REPLACE TRIGGER trg_check_theater_full
    BEFORE INSERT ON 예약
FOR EACH ROW
    DECLARE
        v_seats     NUMBER;
        v_res_count NUMBER;
    BEGIN
        SELECT c.좌석수 
            INTO v_seats
        FROM 상영관 c
            WHERE c.극장번호 = :new.극장번호 AND c.상영관번호 = :new.상영관번호;
    
        SELECT COUNT(*)
            INTO v_res_count
        FROM 예약 r
            WHERE r.극장번호 = new:극장번호 AND r.상영관번호 = :new.상영관번호 AND
                  r.날짜 = :new.날짜;
        
        IF v_res_count >= v_seats THEN
            RAISE_APPLICATION_ERROR(-20003, '해당 상영관 좌석이 모두 매진되었습니다.')
        END IF;
    END;
/
----4. [AFTER INSERT] 예약 정보 자동 기록
CREATE OR REPLACE TRIGGER trg_log_reservation
    AFTER INSERT ON 예약
FOR EACH ROW
    BEGIN
        INSERT INTO 예약이력(극장번호, 상영관번호, 고객번호, 좌석번호, 날짜, 기록일시)
        VALUES (:new.극장번호, :new.상영관번호, :new.고객번호, :new.좌석번호, :new.날짜, SYSDATE);
    END;
/
----5. [BEFORE UPDATE] 비정상 가격 수정 차단
CREATE OR REPLACE TRIGGER trg_validate_room_price
    BEFORE UPDATE OF 가격 ON 상영관
FOR EACH ROW
    BEGIN
        IF :new.가격 <= 0 THEN
            RAISE_APPLICATION_ERROR(-20004, '가격은 0원보다 커야 합니다.');
        END IF;
    END;
/
----6. [AFTER UPDATE] 가격 변경 이력 기록
CREATE OR REPLACE TRIGGER trg_log_price_change
    AFTER UPDATE OF 가격 ON 상영관
FOR EACH ROW
    BEGIN
        INSERT INTO 가격변경이력(극장번호, 상영관번호, 영화제목, 이전가격, 변경가격, 변경일시)
        VALUES (:old.극장번호, :old.상영관번호, :old.영화제목, :old.가격, :new.가격, SYSDATE);
    END;
/
----7. [BEFORE UPDATE] 예약 수보다 적은 좌석 수정 차단
CREATE OR REPLACE TRIGGER trg_check_seat_update
    BEFORE UPDATE OF 좌석수 ON 상영관
FOR EACH ROW
    DECLARE
        v_res_count     NUMBER;
    BEGIN
        SELECT COUNT(*)
            INTO v_res_count
        FROM 예약 r
            WHERE r.극장번호 = :old.극장번호 AND 
                  r.상영관번호 = :old.상영관번호;
        IF :new.좌석수 < v_res_count THEN
            RAISE_APPLICATION_ERROR(-20005, '현재 예약 인원보다 좌석수를 적게 수정할 수 없습니다.');
        END IF;
    END;
/
----8. [BEFORE DELETE] 고객 삭제 시 예약 강제 삭제
CREATE OR REPLACE TRIGGER trg_cascade_cust_del
    BEFORE DELETE ON 고객
FOR EACH ROW
    BEGIN
        DELETE FROM 예약 r WHERE r.고객번호 = :old.고객번호;
    END;
/
----9. [BEFORE DELETE] 상영관 삭제 시 백업 및 정리
CREATE OR REPLACE TRIGGER trg_backup_and_del_room
    BEFORE DELETE ON 상영관
FOR EACH ROW
    BEGIN
        INSERT INTO 삭제영화관이력(극장번호, 상영관번호, 영화제목, 가격, 삭제일시)
        VALUES (:old.극장번호, :old.상영관번호, .old:영화제목, :old.가격, SYSDATE);
    
        DELETE FROM 예약 r
        WHERE r.극장번호 = :old.극장번호 AND r.상영관번호 = :old.상영관번호;
    END;
/
----10. [BEFORE DELETE] 극장 삭제 시 관련 데이터 전체 정리
CREATE OR REPLACE TRIGGER trg_cascade_theater_del
    BEFORE DELETE ON 극장
FOR EACH ROW
    BEGIN
        DELETE FROM 예약 r
        WHERE r.극장번호 = :old.극장번호;

        DELETE FROM 상영관 c
        WHERE c.극장번호 = :old.극장번호;
    END;
/
