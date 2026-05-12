--마당 서점 테이블
--[기본 CRUD]
----1.
CREATE OR REPLACE PROCEDURE info_book(
    --입력 변수
    v_bookid    IN  Book.bookid%TYPE,
    
    --출력 변수
    v_bookname  OUT Book.bookname%TYPE,
    v_publisher OUT Book.publisher%TYPE,
    v_price     OUT Book.price%TYPE
)
IS
BEGIN
    --입력 변수에 해당하는 데이터 저장
    SELECT b.bookname, b.publisher, b.price
        INTO v_bookname, v_publisher, v_price
    FROM Book b
        WHERE b.bookid = v_bookid;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 도서 번호를 찾을 수 없습니다.');
END;
/
------1. 실행
DECLARE
    --결과 출력 변수
    res_name    Book.bookname%TYPE;
    res_pub     Book.publisher%TYPE;
    res_price   Book.price%TYPE;
BEGIN
    --프로시저 호출
    --입력 변수
    info_book(1,    
    --출력 변수
            res_name, res_pub, res_price);  
    
    --결과 출력
    DBMS_OUTPUT.PUT_LINE('도서명: ' || res_name);
    DBMS_OUTPUT.PUT_LINE('출판사: ' || res_pub);
    DBMS_OUTPUT.PUT_LINE('가격: ' || res_price);
END;
/

----2
CREATE OR REPLACE PROCEDURE insert_customer(
    v_custid    IN Customer.custid%TYPE,
    v_name      IN Customer.name%TYPE,
    v_address   IN Customer.address%TYPE,
    v_phone     IN Customer.phone%TYPE
)
IS
BEGIN
    INSERT INTO Customer(custid, name, address, phone)
        VALUES (v_custid, v_name, v_address, v_phone);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('고객 등록 완료: ' || v_name);
END;
/
------2. 실행
EXEC insert_customer(11, '홍길동', '서울시', '010-1234-5678')

----3
CREATE OR REPLACE PROCEDURE revise_price(
    v_bookid    IN Book.bookid%TYPE,
    v_price     IN Book.price%TYPE
)
IS
BEGIN
    UPDATE Book
        SET price = v_price
    WHERE bookid = v_bookid;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 도서가 존재하지 않습니다.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('도서ID' || v_bookid || '가격 수정 완료.');
    END IF;
END;
/
------3. 실행
EXEC revise_price(1, 15000)

----4.
CREATE OR REPLACE PROCEDURE del_customer(
    v_custid    IN Customer.custid%TYPE
)
IS
BEGIN
    DELETE FROM Orders  WHERE custid = v_custid;
    DELETE FROM Customer    WHERE custid = v_custid;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(v_custid || '번 고객 및 주문 내역 삭제 완료.');
END;
/
------4. 실행
EXEC del_customer(1);

----5.
CREATE OR REPLACE PROCEDURE get_orderid(
    v_orderid   IN Orders.orderid%TYPE
)
IS
    v_name      Customer.name%TYPE;
    v_bookname  Book.bookname%TYPE;
    v_saleprice Orders.saleprice%TYPE;
    v_orderdate Orders.orderdate%TYPE;
BEGIN
    SELECT c.name, b.bookname, o.saleprice, o.orderdate
        INTO v_name, v_bookname, v_saleprice, v_orderdate
    FROM Orders o   JOIN Customer c ON o.custid = c.custid
                    JOIN Book b ON o.bookid = b.bookid
        WHERE o.orderid = v_orderid;

    DBMS_OUTPUT.PUT_LINE('고객명: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('도서명: ' || v_bookname);
    DBMS_OUTPUT.PUT_LINE('주문금액: ' || v_saleprice);
    DBMS_OUTPUT.PUT_LINE('주문날짜: ' || v_orderdate);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 주문 번호를 찾을 수 없습니다.');
END;
/
------5. 실행
EXEC get_orderid(1);

--조건 조회
----6.
CREATE OR REPLACE PROCEDURE get_info_book(
    v_publisher IN Book.publisher%TYPE
)
IS
BEGIN
    FOR book_idx IN (
        SELECT bookid, bookname, price
            FROM Book
        WHERE publisher = v_publisher
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || book_idx.bookid ||
                             ' | 명: ' || book_idx.bookname ||
                             ' | 가격: ' || book_idx.price);
    END LOOP;
END;
/

----7
CREATE OR REPLACE PROCEDURE order_dates(
    v_custid    IN Customer.custid%TYPE
)
IS
BEGIN
    FOR order_idx IN (
        SELECT b.bookname, o.saleprice, o.orderdate
            FROM Orders o JOIN Book b ON o.bookid = b.bookid
        WHERE o.custid = v_custid
            ORDER BY o.orderdate ASC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('도서명: ' || order_idx.bookname ||
                             ' | 금액: ' || order_idx.saleprice ||
                             ' | ' || order_idx.orderdate);
    END LOOP;
END;
/

----8
CREATE OR REPLACE PROCEDURE get_order_time(
    v_start_date    IN DATE,
    v_end_date      IN DATE
)
IS
BEGIN
    FOR time_idx IN (
        SELECT c.name, b.bookname, o.saleprice, o.orderdate
            FROM Orders o JOIN Customer c ON o.custid = c.custid
                          JOIN Book b ON o.bookid = b.bookid
        WHERE o.orderdate BETWEEN v_start_date AND v_end_date
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('고객: ' || time_idx.name ||
                             ' | 도서: ' || time_idx.bookname ||
                             ' | 날짜: ' || time_idx.orderdate
                             );
    END LOOP;
END;
/

----9
CREATE OR REPLACE PROCEDURE get_name_price(
    v_bookname  IN Book.bookname%TYPE
)
IS
BEGIN
    FOR book_idx IN (
        SELECT c.name, o.saleprice
            FROM Orders o JOIN Customer c ON o.custid = c.custid
                          JOIN Book b ON o.bookid = b.bookid
        WHERE b.bookname LIKE '%' || v_bookname || '%'
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('고객명: ' || book_idx.name || 
        ' | 주문금액: ' || book_idx.saleprice);
    END LOOP;
END;
/

----10
CREATE OR REPLACE PROCEDURE get_heavy_customer(
    v_min_price     IN Orders.saleprice%TYPE
)
IS
BEGIN
    FOR heavy_idx IN (
        SELECT c.custid, c.name, COUNT(o.orderid) as cnt
            FROM Customer c JOIN Orders o ON c.custid = o.custid
        WHERE o.saleprice >= v_min_price
            GROUP BY c.custid, c.name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || heavy_idx.custid ||
                             ' | 이름: ' || heavy_idx.name ||
                             ' | 주문건수: ' || heavy_idx.cnt);
    END LOOP;
END;
/

--계산 및 통계
----11
CREATE OR REPLACE PROCEDURE get_total_amount(
    v_custid    IN Customer.custid%TYPE,
    v_total     OUT NUMBER
)
IS
BEGIN
    SELECT SUM(o.saleprice) INTO v_total
        FROM Orders o
    WHERE o.custid = v_custid;

    v_total := NVL(v_total, 0);

    DBMS_OUTPUT.PUT_LINE('고객번호 ' || v_custid || '의 총 주문액: ' || v_total);
END;
/

----12
CREATE OR REPLACE PROCEDURE get_publisher_stats(
    v_publisher IN Book.publisher%TYPE    
)
IS
    v_avg   NUMBER;
    v_max   NUMBER;
    v_min   NUMBER;
BEGIN
    SELECT AVG(o.saleprice), MAX(o.saleprice), MIN(o.saleprice)
        INTO v_avg, v_max, v_min
    FROM Orders o JOIN Book b ON o.bookid = b.bookid
        WHERE b.publisher = v_publisher;

    DBMS_OUTPUT.PUT_LINE('출판사 별: ' || v_publisher);
    DBMS_OUTPUT.PUT_LINE('평균가: ' || ROUND(v_avg, 0));
    DBMS_OUTPUT.PUT_LINE('최고가: ' || v_max);
    DBMS_OUTPUT.PUT_LINE('최저가: ' || v_min);
END;
/

----13
CREATE OR REPLACE PROCEDURE get_best_seller(
    v_bookname  OUT Book.bookname%TYPE,
    v_count     OUT NUMBER
)
IS
BEGIN
    SELECT b.bookname, COUNT(*)
        INTO v_bookname, v_count
    FROM Orders o JOIN Book b ON o.bookid = b.bookid
        GROUP BY b.bookname
    ORDER BY COUNT(*) DESC
        FETCH FIRST 1 ROW ONLY;
END;
/

--예외 처리 및 응용
----14.
CREATE OR REPLACE PROCEDURE insert_safe_order(
    v_orderid   IN Orders.orderid%TYPE,
    v_custid    IN Orders.custid%TYPE,
    v_bookid    IN Orders.bookid%TYPE,
    v_saleprice IN Orders.saleprice%TYPE
)
IS
    v_org_price Book.price%TYPE;
BEGIN
    SELECT b.price INTO v_org_price FROM Book b WHERE b.bookid = v_bookid;

    IF v_saleprice > v_org_price THEN
        DBMS_OUTPUT.PUT_LINE('판매가가 정가보다 클 수 없습니다.');
    ELSE
        INSERT INTO Orders(orderid, custid, bookid, saleprice, orderdate)
            VALUES(v_orderid, v_custid, v_bookid, v_saleprice, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('주문내역이 정상적으로 삽입됐습니다.');
    END IF;
END;
/

----15
CREATE OR REPLACE PROCEDURE get_grade(
    v_custid IN Customer.custid%TYPE
)
IS
    v_total NUMBER;
    v_grade VARCHAR2(20);
BEGIN
    SELECT SUM(saleprice) INTO v_total FROM Orders WHERE custid = v_custid;
    v_total := NVL(v_total, 0);

    IF v_total >= 30000 THEN    
        v_grade := 'VIP고객';
    ELSIF v_total >= 10000 THEN 
        v_grade := '일반고객';
    ELSE
        v_grade := '신규 고객';
    END IF;

    DBMS_OUTPUT.PUT_LINE('고객번호: ' || v_custid);
    DBMS_OUTPUT.PUT_LINE('총 구매액: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('등급: ' || v_grade);
END;
/

--극장예약 테이블
--[기본CRUD]
----1
CREATE OR REPLACE PROCEDURE get_theator_info (
    v_theater_id IN 극장.극장번호%TYPE
)
IS
    v_theater_name  극장.극장이름%TYPE;
    v_location      극장.위치%TYPE;
BEGIN
    SELECT t.극장이름, t.위치 INTO v_theater_name, v_location
        FROM 극장 t
    WHERE t.극장번호 = v_theater_id;

    DBMS_OUTPUT.PUT_LINE('극장명: ' || v_theater_name || 
                         ' | 위치: ' || v_location);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 극장번호의 극장은 존재하지 않습니다.');
END;
/

----2
CREATE OR REPLACE PROCEDURE insert_theater(
    v_theater_id    IN 극장.극장번호%TYPE,
    v_theater_name  IN 극장.극장이름%TYPE,
    v_location      IN 극장.위치%TYPE
)
IS
BEGIN
    INSERT INTO 극장(극장번호, 극장이름, 위치)
    VALUES (v_theater_id, v_theater_name, v_location);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('극장 등록이 완료되었습니다.');
END;
/

----3
CREATE OR REPLACE PROCEDURE update_location(
    v_theater_id    IN 극장.극장번호%TYPE,
    v_new_location   IN 극장.위치%TYPE
)
IS
BEGIN
    UPDATE 극장
    SET 위치 = v_new_location
    WHERE 극장번호 = v_theater_id;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 극장에 해당하는 극장번호를 찾을 수 없습니다.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('극장 위치 수정 완료');
    END IF;
END;
/

----4
CREATE OR REPLACE PROCEDURE delete_theater(
    v_theater_id    IN 극장.극장번호%TYPE
)
IS
BEGIN
    DELETE FROM 상영관 WHERE 극장번호 = v_theater_id;
    DELETE FROM 극장 WHERE 극장번호 = v_theater_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('극장 ' || v_theater_id || '번 관련 데이터 삭제 완료');
END;
/
----5
CREATE OR REPLACE PROCEDURE get_theater_info(
    v_theater_id    IN 상영관.극장번호%TYPE,
    v_cinema_id       IN 상영관.상영관번호%TYPE
)
IS
    v_movie_title   상영관.영화제목%TYPE;
    v_price         상영관.가격%TYPE;
    v_seats         상영관.좌석수%TYPE;
BEGIN
    SELECT t.영화제목, t.가격, t.좌석수
        INTO v_movie_title, v_price, v_seats
    FROM 상영관 t
        WHERE t.극장번호 = v_theater_id AND t.상영관번호 = v_cinema_id;

    DBMS_OUTPUT.PUT_LINE('영화제목: ' || v_movie_title);
    DBMS_OUTPUT.PUT_LINE('가격: ' || v_price || '원');
    DBMS_OUTPUT.PUT_LINE('좌석수: ' || v_seats || '석');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 상영관 정보를 찾을 수 없습니다.');
END;
/

--조건조회
----6
CREATE OR REPLACE PROCEDURE get_cheaper(
    v_max_price IN 상영관.가격%TYPE
)
IS
BEGIN
    FOR cinema_idx IN (
        SELECT c.극장번호, c.상영관번호, c.영화제목, c.가격
            FROM 상영관 c
        WHERE c.가격 <= v_max_price
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            '극장: ' || cinema_idx.극장번호 ||
            ' | 상영관: ' || cinema_idx.상영관번호 ||
            ' | 영화: ' || cinema_idx.영화제목 ||
            ' | 가격: ' || cinema_idx.가격
        );
    END LOOP;
END;
/

----7
CREATE OR REPLACE PROCEDURE get_reservation_info(
    v_date  IN 예약.날짜%TYPE
)
IS
BEGIN
    FOR res_idx IN (
        SELECT r.극장번호, r.상영관번호, r.고객번호, r.좌석번호
            FROM 예약 r
        WHERE r.날짜 = v_date
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('극장: ' || res_idx.극장번호 ||
                             ' | 상영관: ' || res_idx.상영관번호 ||
                             ' | 고객: ' || res_idx.고객번호 ||
                             ' | 좌석: ' || res_idx.좌석번호);
    END LOOP;
END;
/

----8
CREATE OR REPLACE PROCEDURE get_reservation_detail(
    v_cust_id   IN 고객.고객번호%TYPE
)
IS
BEGIN
    FOR detail_idx IN (
        SELECT t.극장이름, c.영화제목, r.날짜, r.좌석번호
            FROM 예약 r JOIN 극장 t ON r.극장번호 = t.극장번호
                        JOIN 상영관 c ON r.극장번호 = c.극장번호 AND r.상영관번호 = c.상영관번호
        WHERE r.고객번호 = v_cust_id
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('극장: ' || detail_idx.극장이름 ||
                            ' | 영화: ' || detail_idx.영화제목 ||
                            ' | 날짜: ' || detail_idx.날짜 ||
                            ' | 좌석' || detail_idx.좌석번호);
    END LOOP;
END;
/

----9
CREATE OR REPLACE PROCEDURE get_theater_by_movie(
    v_title IN 상영관.영화제목%TYPE
)
IS
BEGIN
    FOR movie_idx IN (
        SELECT DISTINCT t.극장이름, t.위치
            FROM 상영관 c JOIN 극장 t ON c.극장번호 = t.극장번호
        WHERE c.영화제목 = v_title
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('극장명: ' || movie_idx.극장이름 || 
                             ' | 위치: ' || movie_idx.위치);
    END LOOP;
END;
/

----10
CREATE OR REPLACE PROCEDURE get_reserve_cnt(
    v_theater_id    IN 예약.극장번호%TYPE
)
IS
BEGIN
    FOR count_idx IN (
        SELECT r.상영관번호, COUNT(*) as cnt
            FROM 예약 r
        WHERE r.극장번호 = v_theater_id
            GROUP BY 상영관번호
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('상영관 번호: ' || count_idx.상영관번호 ||
                            ' | 총 예약 건수: ' || count_idx.cnt);
    END LOOP;
END;
/

--계산 및 통계
----11
CREATE OR REPLACE PROCEDURE get_avg_seats(
    v_theater_id    IN 상영관.극장번호%TYPE,
    v_avg_seats     OUT NUMBER
)
IS
BEGIN
    SELECT AVG(c.좌석수)
        INTO v_avg_seats
    FROM 상영관 c
        WHERE c.극장번호 = v_theater_id;
END;
/
------11 실행
DECLARE result NUMBER; 
BEGIN get_avg_seats(1, result);
    DBMS_OUTPUT.PUT_LINE(result);
END;
/
----12
CREATE OR REPLACE PROCEDURE get_reservation_rate(
    v_theater_id    IN 상영관.극장번호%TYPE,
    v_cinema_id       IN 상영관.상영관번호%TYPE
)
IS
    v_total_seats NUMBER;
    v_res_count   NUMBER;
    v_rate        NUMBER;
BEGIN
    --  전체 좌석 수 조회
    SELECT c.좌석수 INTO v_total_seats
        FROM 상영관 c
    WHERE c.극장번호 = v_theater_id AND c.상영관번호 = v_cinema_id;

    --  예약 건수 조회
    SELECT COUNT(*) INTO v_res_count
        FROM 예약 r
    WHERE r.극장번호 = v_theater_id AND r.상영관번호 = v_cinema_id;

    v_rate := (v_res_count / v_total_seats) * 100;

    DBMS_OUTPUT.PUT_LINE('예약률: ' || ROUND(v_rate, 2) || '%');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당하는 상영관 정보가 없습니다.');
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('오류: 좌서 수가 0입니다.');
END;
/

----13.
CREATE OR REPLACE PROCEDURE get_total_spent(
    v_cust_id       IN 예약.고객번호%TYPE,
    v_total_amount  OUT NUMBER
)
IS
BEGIN
    SELECT SUM(c.가격)
        INTO v_total_amount
    FROM 예약 r JOIN 상영관 c ON r.극장번호 = c.극장번호 AND r.상영관번호 = c.상영관번호
        WHERE r.고객번호 = v_cust_id;

    v_total_amount := NVL(v_total_amount, 0);
END;
/

--예외 처리 및 응용
----14.
CREATE OR REPLACE PROCEDURE insert_safe_reservation(
    v_theater_id    IN 예약.극장번호%TYPE,
    v_cinema_id     IN 예약.상영관번호%TYPE,
    v_cust_id       IN 예약.고객번호%TYPE,
    v_seat_no       IN 예약.좌석번호%TYPE,
    v_date          IN 예약.날짜%TYPE
)
IS
    v_total_seats   NUMBER;
    v_res_count     NUMBER;
BEGIN
    --  상영관의 전체 좌석 수 확인
    SELECT 좌석수 INTO v_total_seats
        FROM 상영관 c
    WHERE c.극장번호 = v_theater_id AND c.상영관번호 = v_cinema_id;
    --  해당 날짜 예약 건수 확인
    SELECT COUNT(*) INTO v_res_count
        FROM 예약 r
    WHERE r.극장번호 = v_theater_id AND r.상영관번호 = v_cinema_id AND r.날짜 = v_date;

    --  비교 후 분기
    IF v_res_count >= v_total_seats THEN
        DBMS_OUTPUT.PUT_LINE('오류: 좌석이 모두 매진되었습니다.');
    ELSE
        INSERT INTO 예약(극장번호, 상영관번호, 고객번호, 좌석번호, 날짜)
        VALUES (v_theater_id, v_cinema_id, v_cust_id, v_seat_no, v_date);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('예약이 정상적으로 완료되었습니다.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('오류: 해당 상영관을 찾을 수 없습니다.');
END;
/

----15.
CREATE OR REPLACE PROCEDURE get_empty_cinema(
    v_theater_id    IN 예약.극장번호%TYPE,
    v_date          IN 예약.날짜%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ' || v_date || ' 예약 없는 상영관 목록 ---');

    FOR cin_idx IN (
        SELECT c.상영관번호, c.영화제목
            FROM 상영관 c
        WHERE c.극장번호 = v_theater_id
            AND c.상영관번호 NOT IN (
                SELECT 상영관번호
                    FROM 예약
                WHERE 극장번호 = v_theater_id AND 날짜 = v_date
            )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('상영관: ' || cin_idx.상영관번호 || ' | 영화: ' || cin_idx.영화제목);
    END LOOP;
END;
/

--학생수강 테이블
--[기본 CRUD]
----1.
CREATE OR REPLACE PROCEDURE get_student_info(
    v_stud_id   IN 학생.학번%TYPE
)
IS
    v_name      학생.이름%TYPE;
    v_major     학생.전공%TYPE;
    v_grade     학생.학년%TYPE;

BEGIN
    SELECT s.이름, s.전공, s.학년
        INTO v_name, v_major, v_grade
    FROM 학생 s
        WHERE s.학번 = v_stud_id;

    DBMS_OUTPUT.PUT_LINE('이름: ' || v_name || ' | 전공: ' || v_major ||
                         ' | 학년: ' || v_grade);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 학번의 학생이 존재하지 않습니다.');
END;
/
----2.
CREATE OR REPLACE PROCEDURE insert_student(
    v_stud_id   IN 학생.학번%TYPE,
    v_name      IN 학생.이름%TYPE,
    v_major     IN 학생.전공%TYPE,
    v_grade     IN 학생.학년%TYPE
)
IS
BEGIN
    INSERT INTO 학생(학번, 이름, 전공, 학년)
        VALUES(v_stud_id, v_name, v_major, v_grade);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('학생 등록 완료: ' || v_name);
END;
/
----3.
CREATE OR REPLACE PROCEDURE update_student_grade(
    v_stud_id   IN 학생.학번%TYPE,
    v_new_grade IN 학생.학년%TYPE
)
IS
BEGIN
    UPDATE 학생
        SET 학년 = v_new_grade
    WHERE 학번 = v_stud_id;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 학생의 학번을 찾을 수 없습니다.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(v_stud_id || ' 학번 학생의 학년이 수정되었습니다.');
    END IF;
END;
/
----4.
CREATE OR REPLACE PROCEDURE delete_student_all(
    v_stud_id IN 학생.학번%TYPE
)
IS
BEGIN
    --수강 내역(자식 데이터) 삭제
    DELETE FROM 수강 WHERE 학번 = v_stud_id;
    --학생 정보(부모 데이터) 삭제
    DELETE FROM 학생 WHERE 학번 = v_stud_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE(v_stud_id || ' 학번 학생의 모든 정보가 삭제되었습니다.');
END;
/
----5.
CREATE OR REPLACE PROCEDURE get_subject_details(
    v_sub_code  IN 과목.과목코드%TYPE
)
IS
    v_sub_name  과목.과목이름%TYPE;
    v_room      과목.강의실%TYPE;
    v_day       과목.요일%TYPE;
    v_prof      과목.담당교수%TYPE;
BEGIN
    SELECT s.과목이름, s.강의실, s.요일, s.담당교수
        INTO v_sub_name, v_room, v_day, v_prof
    FROM 과목 s
        WHERE s.과목코드 = v_sub_code;

    DBMS_OUTPUT.PUT_LINE('과목명: ' || v_sub_name);
    DBMS_OUTPUT.PUT_LINE('강의실: ' || v_room || '| 요일: ' || v_day);
    DBMS_OUTPUT.PUT_LINE('담당교수: ' || v_prof);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 과목코드를 찾을 수 없습니다.');
END;
/

--[조건 조회]
----6.
CREATE OR REPLACE PROCEDURE get_student_by_major(
    v_major     IN 학생.전공%TYPE
)
IS
BEGIN
    FOR stud_idx IN(
        SELECT s.학번, s.이름, s.학년
            FROM 학생 s
        WHERE s.전공 = v_major
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('학번: ' || stud_idx.학번 || 
                             ' | 이름: ' || stud_idx.이름 || ' | 학년: ' || stud_idx.학년);
    END LOOP;
END;
/
----7.
CREATE OR REPLACE PROCEDURE get_subjects_by_day(
    v_day IN 과목.요일%TYPE
)
IS
BEGIN
    FOR sub_red IN(
        SELECT s.과목이름, s.강의실, s.담당교수
            FROM 과목 s
        WHERE s.요일 = v_day
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('과목: ' || sub_red.과목이름 || 
                             ' | 강의실: ' || sub_red.강의실 || ' | 교수: ' || sub_red.담당교수);
    END LOOP;
END;
/
----8.
CREATE OR REPLACE PROCEDURE get_student_enrollments(
    v_stud_id   IN 학생.학번%TYPE
)
IS
BEGIN
    FOR enroll_idx IN (
        SELECT s.과목이름, r.수강학기, r.성적
            FROM 수강 r JOIN 과목 s ON r.과목코드 = s.과목코드
        WHERE r.학번 = v_stud_id
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('과목: ' || enroll_idx.과목이름 || ' | 학기: ' || enroll_idx.수강학기 ||
                             ' | 성적: ' || enroll_idx.성적);
    END LOOP;
END;
/
----9.
CREATE OR REPLACE PROCEDURE get_student_by_prof(
    v_prof      IN 과목.담당교수%TYPE
)
IS
BEGIN
    FOR idx IN (
        SELECT DISTINCT s.이름, s.전공
            FROM 학생 s JOIN 수강 r ON s.학번 = r.학번
                        JOIN 과목 c ON r.과목코드 = c.과목코드
        WHERE c.담당교수 = v_prof
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('학생명: ' || idx.이름 || ' | 전공: ' || idx.전공);
    END LOOP;
END;
/
----10.
CREATE OR REPLACE PROCEDURE get_enrollment_count(
    v_sub_code      IN 과목.과목코드%TYPE
)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
        FROM 수강 r
    WHERE r.과목코드 = v_sub_code;
    DBMS_OUTPUT.PUT_LINE('과목코드 ' || v_sub_code || '의 총 수강 인원: ' || v_count || '명');
END;
/

--[계산 및 통계]
----11.
CREATE OR REPLACE PROCEDURE get_avg_grade_by_major(
    v_major     IN 학생.전공%TYPE,
    v_avg_grade OUT NUMBER
)
IS
BEGIN
    SELECT AVG(학년) INTO v_avg_grade FROM 학생 WHERE 전공 = v_major;
    v_avg_grade := NVL(v_avg_grade, 0);
END;
/
----12
CREATE OR REPLACE PROCEDURE get_student_avg_score(
    v_stud_id   IN 학생.학번%TYPE
)
IS
    v_avg_score NUMBER;
BEGIN
    SELECT AVG(성적) INTO v_avg_score FROM 수강 WHERE 학번 = v_stud_id;

    DBMS_OUTPUT.PUT_LINE('학번 ' || v_stud_id || '의 평균 성적: ' || ROUND(NVL(v_avg_score, 0), 2));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('수강 내역이 없습니다.');
END;
/
----13.
CREATE OR REPLACE PROCEDURE get_score_range(
    v_sub_code  IN 과목.과목코드%TYPE,
    v_max_score OUT NUMBER,
    v_min_score OUT NUMBER
)
IS
BEGIN
    SELECT MAX(r.성적), MIN(r.성적)
        INTO v_max_score, v_min_score
    FROM 수강 r
        WHERE r.과목코드 = v_sub_code;

    v_max_score := NVL(v_max_score, 0);
    v_min_score := NVL(v_min_score, 0);
END;
/

--[예외 처리 및 응용]
----14
CREATE OR REPLACE PROCEDURE insert_safe_enrollment(
    v_sub_code  IN 수강.과목코드%TYPE,
    v_stud_id   IN 수강.학번%TYPE,
    v_semester  IN 수강.수강학기%TYPE,
    v_score     IN 수강.성적%TYPE
)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) 
        INTO v_count
    FROM 수강 r
        WHERE r.과목코드 = v_sub_code AND
                r.학번 = v_stud_id;
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('오류: 이미 수강 중입니다.');
    ELSE
        INSERT INTO 수강(과목코드, 학번, 수강학기, 성적)
        VALUES (v_sub_code, v_stud_id, v_semester, v_score);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('수강 신청이 성공적으로 진행되었습니다.');
    END IF;
END;
/
----15
CREATE OR REPLACE PROCEDURE get_missing_scores(
    v_semester      IN 수강.수강학기%TYPE,
    v_miss_count    OUT NUMBER
)
IS
BEGIN
    v_miss_count := 0;
    DBMS_OUTPUT.PUT_LINE('--- ' || v_semester || ' 성적 미입력 명단 ---');
    FOR miss_idx IN (
        SELECT r.학번, s.이름, c.과목이름
            FROM 수강 r JOIN 학생 s ON r.학번 = s.학번
                        JOIN 과목 c ON r.과목코드 = c.과목코드
        WHERE r.수강학기 = v_semester AND r.성적 IS NULL
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('학번: ' || miss_idx.학번 || ' | 이름: ' || miss_idx.이름 ||
                             ' | 과목: ' || miss_idx.과목이름);
        v_miss_count := v_miss_count + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('총 미입력 건수: ' || v_miss_count);
END;
/
