--문제 1.
CREATE VIEW v_saleperson_info AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 s;

--문제 2.
CREATE VIEW v_high_salary_sp AS
    SELECT s.NAME AS 이름, s.SALARY AS 급여
        FROM SALESPERSON_0402 s
    WHERE s.SALARY >= 10000
WITH READ ONLY;

--문제 3.
CREATE VIEW v_young_salesperson AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 s
    WHERE s.AGE < 30;

--문제 4.
CREATE VIEW v_la_customer AS
    SELECT C.NAME AS 이름, c.CITY AS 도시, c.INDUSTRYTYPE AS 직업
        FROM CUSTOMER_0402 c
    WHERE c.CITY = 'LA';

--문제 5.
CREATE VIEW v_developer_customer AS
    SELECT c.NAME AS 이름, c.CITY AS 도시, c.INDUSTRYTYPE AS 직업
        FROM CUSTOMER_0402 c
    WHERE c.INDUSTRYTYPE = '개발자';
    
--문제 6.
CREATE VIEW v_high_amount_order AS
    SELECT o.NUMBER_0402 AS 주문번호, o.CUSTNAME AS 고객이름, o.SALESPERSON AS 담당판매원, o.AMOUNT AS 주믄금액
        FROM ORDER_0402 o
    WHERE o.AMOUNT >= 15000;

--문제 7.
CREATE VIEW v_mid_salary_sp AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 s
    WHERE s.SALARY BETWEEN 8000 AND 12000;

--문제 8.
CREATE VIEW v_tom_order AS
    SELECT o.NUMBER_0402 AS 주문번호, o.CUSTNAME AS 고객이름, o.SALESPERSON AS 담당판매원, o.AMOUNT AS 주문금액
        FROM ORDER_0402 o
    WHERE o.SALESPERSON = 'TOM';

--문제 9.
CREATE VIEW v_s_salesperson AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 s
    WHERE s.NAME LIKE 'S%';

--문제 10.
CREATE VIEW v_mid_amount_order AS
    SELECT o.NUMBER_0402 AS 주문번호, o.CUSTNAME AS 고객이름, o.SALESPERSON AS 담당판매원, o.AMOUNT AS 주문금액
        FROM ORDER_0402 o
    WHERE o.AMOUNT BETWEEN 5000 AND 10000
WITH CHECK OPTION;

--(복합 뷰)
--문제 1.
CREATE VIEW v_sp_order_summary AS
    SELECT o.SALESPERSON AS 판매원이름, SUM(o.AMOUNT) AS 총주문금액, COUNT(o.NUMBER_0402) AS 주문횟수
        FROM ORDER_0402 o
    GROUP BY o.SALESPERSON;
    
--문제 2.
CREATE VIEW v_cust_order_summary AS
    SELECT o1.고객이름, o2.CITY AS 도시, o1.총주문금액, o1.주문횟수
        FROM (SELECT o.CUSTNAME AS 고객이름, SUM(o.AMOUNT) AS 총주문금액, COUNT(o.NUMBER_0402) AS 주문횟수
                FROM ORDER_0402 o JOIN CUSTOMER_0402 c ON o.CUSTNAME = c.NAME
              GROUP BY o.CUSTNAME) o1 
    JOIN CUSTOMER_0402 o2 ON o1.고객이름 = o2.NAME;
    
--문제 3.
CREATE VIEW v_above_avg_salary AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 s
    WHERE s.SALARY > (
        SELECT AVG(SALARY)
            FROM SALESPERSON_0402);

--문제 4.
CREATE VIEW v_no_order_sp AS
    SELECT s.NAME AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM SALESPERSON_0402 S LEFT JOIN ORDER_0402 o ON s.NAME = o.SALESPERSON
    WHERE number_0402 IS NULL;

--문제 5.
CREATE VIEW v_la_order_sp AS
    SELECT DISTINCT o.SALESPERSON AS 이름, s.AGE AS 나이, s.SALARY AS 급여
        FROM ORDER_0402 o JOIN CUSTOMER_0402 c ON o.CUSTNAME = c.NAME
    JOIN SALESPERSON_0402 s ON o.SALESPERSON = s.NAME
        WHERE c.CITY = 'LA';

--문제 6.
CREATE VIEW v_above_avg_order_sp AS
    SELECT o1.이름, o1.평균주문금액
        FROM (  SELECT o.SALESPERSON AS 이름, ROUND(AVG(o.AMOUNT)) AS 평균주문금액
                    FROM ORDER_0402 o
                GROUP BY o.SALESPERSON) o1 JOIN ORDER_0402 o2 ON o1.이름 = o2.SALESPERSON
    WHERE o2.AMOUNT > o1.평균주문금액;    

--문제 7.
CREATE VIEW v_no_order_cust AS
    SELECT c.NAME AS 이름, c.CITY AS 도시, c.INDUSTRYTYPE AS 직업
        FROM CUSTOMER_0402 c 
    WHERE NOT EXISTS (
        SELECT 1
            FROM ORDER_0402
        WHERE CUSTNAME = c.NAME);

--문제 8.
CREATE VIEW v_frequent_sp AS
    SELECT o.SALESPERSON AS 이름, COUNT(o.NUMBER_0402) AS 주문횟수, SUM(o.AMOUNT) AS 총주문금액
        FROM ORDER_0402 o
    GROUP BY o.SALESPERSON
        HAVING COUNT(o.NUMBER_0402) >= 2;

--문제 9.
CREATE VIEW v_city_order_stats AS
    SELECT c.CITY AS 도시, SUM(o.AMOUNT) AS 총주문금액, COUNT(o.NUMBER_0402) AS 주문건수
        FROM CUSTOMER_0402 c JOIN ORDER_0402 o ON c.NAME = o.CUSTNAME
    GROUP BY c.CITY;

--문제 10.
CREATE VIEW v_sp_order_ration AS
    SELECT o1.판매원이름, s.SALARY AS 급여, o1.최고주문금액, o1.최저주문금액, o1.평균주문금액, ROUND((o1.총주문금액 / s.SALARY) * 100, 2) || '%' AS 급여대비주문비율
        FROM (  SELECT o.SALESPERSON AS 판매원이름, MAX(o.AMOUNT) AS 최고주문금액, MIN(o.AMOUNT) AS 최저주문금액, ROUND(AVG(o.AMOUNT), 2) AS 평균주문금액, SUM(o.AMOUNT) AS 총주문금액
                    FROM ORDER_0402 o
                GROUP BY o.SALESPERSON) o1 JOIN SALESPERSON_0402 s ON o1.판매원이름 = s.NAME;

--문제 11.
CREATE VIEW v_industry_order_stats AS
    SELECT c.INDUSTRYTYPE AS 직업, SUM(o.AMOUNT) AS 총주문금액, ROUND(AVG(o.AMOUNT), 2) AS 평균주문금액
        FROM CUSTOMER_0402 c JOIN ORDER_0402 o ON c.NAME = o.CUSTNAME
    GROUP BY c.INDUSTRYTYPE;

--문제 12.
CREATE VIEW v_sp_order_over_salary AS
    SELECT o1.이름, s.SALARY AS 급여, o1.총주문금액
        FROM (  SELECT o.SALESPERSON AS 이름, SUM(o.AMOUNT) AS 총주문금액
                    FROM ORDER_0402 o
                GROUP BY o.SALESPERSON) o1 JOIN SALESPERSON_0402 s ON o1.이름 = s.NAME
    WHERE s.SALARY < o1.총주문금액;
    
--문제 13.
CREATE VIEW v_sp_cust_count AS
    SELECT o.SALESPERSON AS 판매원이름, COUNT(DISTINCT o.CUSTNAME) AS 담당고객수, SUM(o.AMOUNT) AS 총주문금액
        FROM ORDER_0402 o
    GROUP BY o.SALESPERSON;

--문제 14.
CREATE VIEW v_max_order_cus AS
    SELECT c.NAME AS 이름, c.CITY AS 도시, c.INDUSTRYTYPE AS 직업, o.AMOUNT 주문금액
        FROM CUSTOMER_0402 c JOIN ORDER_0402 o ON c.NAME = o.CUSTNAME
    WHERE o.AMOUNT = (SELECT MAX(AMOUNT)
        FROM ORDER_0402);

--문제 15.
CREATE VIEW v_sp_order_ratio AS
    SELECT o.SALESPERSON AS 판매원이름, SUM(o.AMOUNT) AS 총주문금액, SUM(SUM(o.AMOUNT)) OVER() AS 전체주문금액,
        ROUND((SUM(o.AMOUNT) / SUM(SUM(o.AMOUNT)) OVER()) * 100, 2) AS 주문비중
    FROM ORDER_0402 o
        GROUP BY o.SALESPERSON;

--[극장 데이터베이스]_3장 연습문제 20번 기준
--문제 1.
CREATE VIEW v_theater_info AS
    SELECT * FROM 극장 t;

--문제 2.
CREATE VIEW v_gangnam_theater AS
    SELECT t.극장번호, t.극장이름
        FROM 극장 t
    WHERE t.위치='강남'
WITH READ ONLY;

--문제 3.
CREATE VIEW v_high_price_screen AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.가격
        FROM 상영관 c
    WHERE c.가격 >= 10000
WITH READ ONLY;

--문제 4.
CREATE VIEW v_large_screen AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.좌석수
        FROM 상영관 c
    WHERE c.좌석수 >= 100;

--문제 5.
CREATE VIEW v_gangnam_customer AS
    SELECT p.고객번호, p.이름, p.주소
        FROM 고객 p
    WHERE p.주소 = '강남'
WITH READ ONLY;
    
--문제 6.
CREATE VIEW v_reservation_20250901 AS
    SELECT r.극장번호, r.상영관번호, r.고객번호, r.좌석번호, r.날짜
        FROM 예약 r
    WHERE '2025-9-1' = TO_CHAR(r.날짜, 'yyyy-mm-dd');

--문제 7.
CREATE VIEW v_mid_price_screen AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.가격
        FROM 상영관 c
    WHERE c.가격 BETWEEN 7500 AND 10000
WITH READ ONLY;

--문제 8.
CREATE VIEW v_front_seat_reservation AS
    SELECT r.극장번호, r.상영관번호, r.고객번호, r.좌석번호
        FROM 예약 r
    WHERE r.좌석번호 <= 20;

--문제 9.
CREATE VIEW v_movie_screen AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.가격, c.좌석수
        FROM 상영관 c
    WHERE c.영화제목 LIKE '%영화%'
WITH READ ONLY;

--문제 10.
CREATE VIEW v_jamsil_customer AS
    SELECT p.고객번호, p.이름, p.주소
        FROM 고객 p
    WHERE p.주소 = '잠실'
WITH CHECK OPTION;

--(극장 데이터베이스 복합 뷰 문제)
--문제 1.
CREATE VIEW v_theater_screeen_stats AS
    SELECT c.극장번호, COUNT(c.상영관번호) AS 상영관수, ROUND(AVG(c.가격), 2) AS 평균가격
        FROM 상영관 c
    GROUP BY c.극장번호;

--문제 2.
CREATE VIEW v_theater_max_price AS
    SELECT t.극장이름, c.영화제목, c.가격
        FROM 상영관 c JOIN 극장 t ON c.극장번호 = t.극장번호
    WHERE c.가격 = (SELECT MAX(가격)
                        FROM 상영관);

--문제 3.
CREATE VIEW v_customer_reservation_count AS
    SELECT p.이름 AS 고객이름, p.주소, r1.총예약횟수
        FROM (  SELECT r.고객번호, COUNT(*) AS 총예약횟수
                    FROM 예약 r
                GROUP BY r.고객번호) r1 JOIN 고객 p ON r1.고객번호 = p.고객번호;
                
--문제 4.
CREATE VIEW v_no_reservation_customer AS
    SELECT p.고객번호, p.이름, p.주소
        FROM 고객 p LEFT JOIN 예약 r ON p.고객번호 = r.고객번호
    WHERE r.극장번호 IS NULL;

--문제 5.
CREATE VIEW v_no_theater_reservation_stats AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.가격
        FROM 상영관 c LEFT JOIN 예약 r ON c.상영관번호 = r.상영관번호
    WHERE r.좌석번호 IS NULL;

--문제 6.
CREATE VIEW v_theater_reservation_stats AS
    SELECT t.극장이름, COUNT(*) AS 총예약건수, COUNT(*) AS 총예약좌석수
        FROM 극장 t JOIN 예약 r ON t.극장번호 = r.극장번호
    GROUP BY t.극장이름;

--문제 7.
CREATE VIEW v_gangnam_customer_reservation AS
    SELECT p.이름 AS 고객이름, r.극장번호, r.상영관번호, r.좌석번호, r.날짜
        FROM 예약 r LEFT JOIN 고객 p ON r.고객번호 = p.고객번호
    WHERE p.주소 = '강남';

--문제 8.
CREATE VIEW v_screen_reservation_rate AS
    SELECT c.극장번호, c.상영관번호, c.영화제목, c.좌석수, r1.예약건수, ROUND((r1.예약건수/c.좌석수) * 100, 2) || '%' AS 예약률
        FROM (  SELECT r.상영관번호, count(*) AS 예약건수
                    FROM 예약 r
                GROUP BY r.상영관번호) r1 LEFT JOIN 상영관 c ON r1.상영관번호 = c.상영관번호;
--문제 9.        
SELECT p.이름, p.주소, r1.예약횟수
    FROM (  SELECT r.고객번호, COUNT(*) AS 예약횟수
                FROM 예약 r
            GROUP BY r.고객번호) r1 LEFT JOIN 고객 p ON r1.고객번호 = p.고객번호;
                
--문제 10.
CREATE VIEW v_movie_reservation_stats AS
    SELECT c.영화제목, r1.총예약건수, SUM(c.가격) OVER(PARTITION BY c.영화제목) AS 총예약금액
        FROM (  SELECT r.상영관번호, COUNT(*) AS 총예약건수
                    FROM 예약 r
                GROUP BY r.상영관번호) r1 LEFT JOIN 상영관 c ON r1.상영관번호 = c.상영관번호;

--문제 11.
CREATE VIEW v_location_screen_stats AS
    SELECT t.위치, ROUND(AVG(c.가격), 2) AS 평균가격, COUNT(*) AS 총상영관수 
        FROM 상영관 c LEFT JOIN 극장 t ON c.극장번호 = t.극장번호
    GROUP BY t.위치;

--문제 12.
CREATE VIEW v_customer_last_reservation AS
    SELECT p.이름 AS 고객이름, r1.극장번호, r1.상영관번호, r1.최근예약날짜
        FROM (  SELECT r.고객번호, r.극장번호, r.상영관번호 ,MAX(r.날짜) OVER(PARTITION BY r.고객번호) AS 최근예약날짜
                    FROM 예약 r) r1 JOIN 고객 p ON r1.고객번호 = p.고객번호;
                    
--문제 13.
CREATE VIEW v_above_avg_price_screen AS
    SELECT t.극장이름, c.상영관번호, c.영화제목, c.가격
        FROM 상영관 c JOIN 극장 t ON c.극장번호 = t.극장번호
    WHERE c.가격 > (  SELECT AVG(가격)
                        FROM 상영관);

--문제 14.
CREATE VIEW v_most_reserved_screen AS
    WITH screen_01 AS (
        SELECT t.극장이름, c.상영관번호, c.영화제목, COUNT(r.좌석번호) AS 예약건수
            FROM 극장 t JOIN 상영관 c ON t.극장번호 = c.극장번호
        LEFT JOIN 예약 r ON c.상영관번호 = r.상영관번호
            GROUP BY t.극장이름, c.상영관번호, c.영화제목
    ), seat_01 AS (
        SELECT 극장이름, MAX(예약건수) AS 최대건수
            FROM screen_01
        GROUP BY 극장이름
    )
    SELECT s.극장이름, s.상영관번호, s.영화제목, s.예약건수
        FROM screen_01 s JOIN seat_01 s1 ON s.극장이름 = s1.극장이름 AND s.예약건수 = s1.최대건수;

--문제 15.
CREATE VIEW v_customer_payment_ratio AS
    SELECT p.이름 AS 고객이름, SUM(c.가격) AS 총예약금액, SUM(SUM(c.가격)) OVER() AS 전체예약금액,
        ROUND((SUM(c.가격) / SUM(SUM(c.가격)) OVER()) * 100, 2) AS 예약비중
    FROM 고객 p
        JOIN 예약 r ON p.고객번호 = r.고객번호
    JOIN 상영관 c ON r.상영관번호 = c.상영관번호
        GROUP BY p.이름;
