--뷰 연습문제
--(1)
CREATE VIEW highorders
    AS SELECT b.BOOKID AS 도서번호, b.BOOKNAME AS 도서이름, c.NAME as 고객이름, b.PUBLISHER AS 출판사, b.PRICE AS 판매가격
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
WHERE b.PRICE >= 20000;

--(2)
SELECT 도서이름, 고객이름 FROM highorders;

--(3)
CREATE OR REPLACE VIEW highorders
    AS SELECT b.BOOKID AS 도서번호, b.BOOKNAME AS 도서이름, c.NAME as 고객이름, b.PUBLISHER AS 출판사
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID;
    
SELECT 도서이름, 고객이름 FROM highorders;

--4/16 뷰 실습예제
-- 고객 테이블: Customer(custid, name, address, phone)
-- 도서 테이블: Book(bookid, bookname, publisher, price)
-- 주문 테이블: Orders(orderid, custid, bookid, saleprice, orderdate)
--문제 1.
CREATE VIEW v_cust_order_summary
    AS SELECT c.NAME AS 고객이름, SUM(o.SALEPRICE) AS 총판매금액, COUNT(o.orderid) AS 주문횟수
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
GROUP BY c.NAME;

--문제 2.
CREATE VIEW v_book_sales
    AS SELECT b.BOOKNAME AS 도서명, b.PUBLISHER AS 출판사, COUNT(o.ORDERID) AS 주문횟수, SUM(o.SALEPRICE) AS 총판매금액
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
GROUP BY 도서명, 출판사;

--문제 3.
CREATE VIEW v_cust_last_orders
    AS SELECT c.NAME as 고객이름, c.ADDRESS as 주소, MAX(o.ORDERDATE) as 최근주문일
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    GROUP BY 고객이름, 주소;
    
--문제 4.
CREATE VIEW v_discounted_orders
    AS SELECT o.ORDERID AS 주문번호, c.NAME AS 고객이름, b.BOOKNAME AS 도서명, b.PRICE AS 정가, o.SALEPRICE AS 판매가, (b.PRICE - o.SALEPRICE) AS 할인금액
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
WHERE (b.PRICE - o.SALEPRICE) > 0;
    
-- 문제 5.
CREATE VIEW v_publisher_stats
    AS SELECT b.PUBLISHER AS 출판사, ROUND(AVG(o.SALEPRICE),2) AS 평균판매가, SUM(o.SALEPRICE) AS 최고판매가
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    GROUP BY b.PUBLISHER;
    
--문제 6.
CREATE VIEW v_vip_customer
    AS SELECT c.NAME AS 고객이름, SUM(o.SALEPRICE) AS 총주문금액
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    GROUP BY c.NAME;
    
--문제 7.
CREATE VIEW v_orders_2024
    AS SELECT c.NAME AS 고객이름, b.BOOKNAME AS 도서명, o.SALEPRICE AS 판매가격, o.ORDERDATE AS 주문일자
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
WHERE TO_CHAR(o.ORDERDATE, 'yyyy') = 2024;

--문제 8.
CREATE VIEW v_unsold_books
    AS SELECT b.BOOKNAME AS 도서명, b.PUBLISHER AS 출판사, b.PRICE AS 정가
FROM BOOK b JOIN ORDERS o ON b.BOOKID = o.BOOKID
    WHERE o.ORDERID IS NULL;
    
--문제 9.
CREATE VIEW v_cust_max_order
    AS SELECT c.NAME AS 고객이름, b.BOOKNAME AS 도서명, o.SALEPRICE AS 최고구매금액
        FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    JOIN BOOK b ON o.BOOKID = b.BOOKID
        WHERE o.SALEPRICE = (
    SELECT MAX(o1.SALEPRICE)
        FROM ORDERS o1
    WHERE o1.CUSTID = o.CUSTID);

--문제 10.
CREATE OR REPLACE VIEW v_book_price_compare
    AS SELECT b.BOOKNAME AS 도서명, c.NAME AS 고객이름, o.SALEPRICE AS 판매가,
AVG(o.SALEPRICE) OVER(PARTITION BY b.BOOKID) AS 도서평균판매가, 
    o.SALEPRICE - AVG(o.SALEPRICE) OVER(PARTITION BY b.BOOKID) AS 차이
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    JOIN BOOK b ON o.BOOKID = b.BOOKID;

--[복합 뷰 문제]

--문제 1.
CREATE VIEW v_publisher_sales
    AS SELECT b.PUBLISHER, COUNT(o.ORDERID) AS 판매도서수, SUM(o.SALEPRICE) AS 총판매금액
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    GROUP BY(b.PUBLISHER);
    
--문제 2.
CREATE VIEW v_above_avg_custmoer
    AS SELECT c.NAME, ROUND(AVG(o.SALEPRICE), 2) AS 평균구매금액
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    WHERE o.SALEPRICE > (
SELECT AVG(o1.SALEPRICE)
    FROM ORDERS o1
) GROUP BY c.NAME;

--문제 3.
CREATE VIEW v_orders_detail
    AS SELECT b.BOOKNAME AS 도서명, c.NAME AS 고객이름, o.ORDERDATE AS 주문일자, o.SALEPRICE AS 판매가격
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    JOIN BOOK b ON o.BOOKID = b.BOOKID
ORDER BY o.SALEPRICE DESC;

--문제 4.
CREATE VIEW v_frequent_customer
    AS SELECT c.NAME as 고객이름, COUNT(o.ORDERID) AS 주문횟수
FROM ORDERS o JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
    GROUP BY c.NAME
HAVING COUNT(c.NAME) > 1;

--문제 5.
CREATE VIEW v_last_ordered_book AS
    SELECT o1.고객이름, o1.도서명, o1.주문일자
FROM(SELECT c.NAME AS 고객이름, b.BOOKNAME AS 도서명, o.ORDERDATE AS 주문일자, 
    ROW_NUMBER() OVER(PARTITION BY c.CUSTID ORDER BY o.ORDERDATE DESC) as 행번호
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID) o1
WHERE 행번호 = 1;
  
--문제 6.
CREATE VIEW v_publisher_discount_rate AS
    SELECT b.PUBLISHER AS 출판사, ROUND(AVG((b.PRICE - o.SALEPRICE) * 100 / b.PRICE) OVER(PARTITION BY b.PUBLISHER), 2) AS 평균할인율
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    WHERE b.PRICE > o.SALEPRICE;

--문제 7.
CREATE VIEW v_customer_order_status AS
    SELECT DISTINCT c.NAME, 
        CASE WHEN o.ORDERID IS NULL THEN '주문있음' 
            ELSE '주문없음' 
        END AS 주문여부
FROM CUSTOMER c LEFT JOIN ORDERS o ON c.CUSTID = o.CUSTID;

--문제 8.
CREATE VIEW v_monthly_sales AS
    SELECT TO_CHAR(o.ORDERDATE, 'yyyy') AS 년도, TO_CHAR(o.ORDERDATE, 'mm') AS 월,
        SUM(o.SALEPRICE) AS 총판매금액, COUNT(*) AS 주문건수
    FROM ORDERS o GROUP BY TO_CHAR(o.ORDERDATE, 'yyyy'), TO_CHAR(o.ORDERDATE, 'mm')
        ORDER BY 년도, 월;

--문제 9.
CREATE VIEW v_publisher_loyal_customer AS
    SELECT c.NAME AS 고객이름, b.PUBLISHER AS 출판사, COUNT(b.BOOKID) as 구매종류수
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
GROUP BY c.NAME, b.PUBLISHER
    HAVING COUNT(b.BOOKID) >= 2;

--문제 10.
CREATE VIEW v_book_price_stats AS
    SELECT b.BOOKNAME AS 도서명, b.PUBLISHER AS 출판사, MAX(o.SALEPRICE) AS 최고판매가, MIN(o.SALEPRICE) AS 최저판매가,
            ROUND(AVG(o.SALEPRICE), 2) AS 평균판매가, MAX(o.SALEPRICE - o.SALEPRICE) AS 최대할인금액
FROM ORDERS o JOIN BOOK b ON o.BOOKID = b.BOOKID
    JOIN CUSTOMER c ON o.CUSTID = c.CUSTID
GROUP BY b.BOOKNAME, b.PUBLISHER;

--[사원 데이터베이스]
--문제 1.
CREATE VIEW v_emp_basic AS
    SELECT e.EMPNO as 사원번호, e.NAME as 이름, d.DEPTNAME as 부서명, e.POSITION as 직급, e.SALARY as 급여
        FROM EMPLOYEE e JOIN DEPARTMENT ON e.DEPTNO = d.DEPTNO;
--문제 2.
CREATE VIEW v_high_salary_emp AS
    SELECT e.NAME as 이름, e.POSITION as 직급, e.SALARY as 급여, d.DEPTNAME as 부서명
        FROM EMPLOYEE e JOIN DEPARTMENT ON e.DEPTNO = d.DEPTNO
    WHERE e.SALARY >= 500;
WITH READ ONLY;

--문제 3.
CREATE VIEW v_active_projects AS
    SELECT p.PROJNO AS 프로젝트번호, p.PROJNAME AS 프로젝트명, p.START_DATE AS 시작일, p.END_DATE AS 종료일
        FROM PROJECT p
    WHERE SYSDATE BETWEEN p.START_DATE AND p.END_DATE;
    
--문제 4.
CREATE VIEW v_veteran_employee AS
    SELECT e.EMPNO AS 사원번호, e.NAME AS 이름, d.DEPTNAME AS 부서명, e.EMP_DATE AS 입사일, (TO_CHAR(SYSDATE,'yyyy') - TO_CHAR(e.EMP_DATE,'yyyy')) AS 근속연수
        FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
    WHERE TO_CHAR(e.EMP_DATE, 'yyyy') < 2019;

--문제 5.
CREATE VIEW v_seoul_department AS
    SELECT d.DEPTNO AS 부서번호, d.DEPTNAME AS 부서명, d.BUDGET AS 예산 
        FROM DEPARTMENT d
    WHERE d.ADDRESS = '서울';

--문제 6.
CREATE VIEW v_senior_position AS
    SELECT e.EMPNO AS 사원번호, e.NAME AS 이름, e.POSITION AS 직급, e.SALARY AS 급여
        FROM EMPLOYEE e
    WHERE POSITION IN ('부장','이사')
WITH READ ONLY;

--문제 7.    
CREATE VIEW v_pm_role AS
    SELECT e.EMPNO AS 사원번호, w.PROJNO AS 프로젝트번호, w.ROLE AS 담당역할, w.HOURS_WORKED AS 투입시간
        FROM WORKS w JOIN EMPLOYEE e ON w.EMPNO = e.EMPNO
    WHERE w.ROLD = 'PM';

--문제 8.
CREATE VIEW v_junior_emp AS
    SELECT e.NAME AS 이름, e.POSITION AS 직급, e.SALARY AS 급여, e.EMP_DATE AS 입사일
        FROM EMPLOYEE e
    WHERE e.SALARY < 300 AND TO_CHAR(e.EMP_DATE, 'YYYY') >= 2022;
    
--문제 9.
CREATE VIEW v_large_budget_project AS
    SELECT p.PROJNAME AS 프로젝트명, p.START_DATE AS 시작일, p.END_DATE AS 종료일, p.BUDGET AS 예산
        FROM PROJECT p
    WHERE p.BUDGET >= 10000
WITH READ ONLY;

--문제 10.
CREATE VIEW v_top_executive AS
    SELECT e.EMPNO AS 사원번호, e.NAME AS 이름, d.DEPTNAME AS 부서명, e.POSITION AS 직급, e.SALARY AS 급여
        FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
    WHERE e.BOSS IS NULL AND e.SALARY >= 700
WITH READ ONLY;

--[복합 뷰]
--문제 1.
CREATE VIEW v_dept_salary_stats AS
    SELECT d.DEPTNAME AS 부서명, AVG(e.SALARY) AS 평균급여, MAX(e.SALARY) AS 최고급여, MIN(e.SALARY) AS 최저급여
        FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
    GROUP BY d.DEPTNAME;

--문제 2.
CREATE VIEW v_emp_project_summary AS
    SELECT e.NAME AS 사원이름, COUNT(w.PROJNO) AS 참여프로젝트수, SUM(w.HOURS_WORKED) AS 투입시간
        FROM EMPLOYEE e LEFT JOIN WORKS w ON e.EMPNO = w.EMPNO
    GROUP BY e.NAME;

--문제 3.
CREATE VIEW v_dept_budget_ratio AS
        SELECT d.DEPTNAME AS 부서명, d.BUDGET AS 부서예산, AVG(e.SALARY) AS 평균급여, ROUND((AVG(e.SALARY)/d.BUDGET) * 100, 2) AS 급여예산비율
    FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
        GROUP BY d.DEPTNAME, d.BUDGET;

--문제 4.
CREATE VIEW v_active_project_emp AS
    SELECT e.NAME AS 사원이름, d.DEPTNAME AS 부서명, p.PROJNAME AS 프로젝트명, w.ROLE AS 담당역할
        FROM PROJECT p JOIN WORKS w ON p.PROJNO = w.PROJNO
    JOIN EMPLOYEE e ON w.EMPNO = e.EMPNO
        JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
    WHERE SYSDATE BETWEEN p.START_DATE AND p.END_DATE;

--문제 5.
CREATE VIEW v_no_project_emp AS
    SELECT e.EMPNO AS 사원번호, e.NAME AS 이름, d.DEPTNAME AS 부서명, e.POSITION AS 직급
        FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
    LEFT JOIN WORKS w ON e.EMPNO = w.EMPNO
        WHERE w.PROJNO IS NULL;

--문제 6.
CREATE VIEW v_project_stats AS
    SELECT p.PROJNAME AS 프로젝트명, COUNT(w.EMPNO) AS 참여인원수, SUM(w.HOURS_WORKED) AS 총투입시간, ROUND(AVG(w.HOURS_WORKED), 2) AS 평균투입시간
        FROM WORKS w JOIN PROJECT p ON w.PROJNO = p.PROJNO
    GROUP BY p.PROJNAME;
    
--문제 7.
CREATE VIEW v_above_dept_avg AS
    SELECT e1.이름, e1.부서명, e1.급여, e1.부서평균급여
        FROM (SELECT e.NAME AS 이름, d.DEPTNAME AS 부서명, e.SALARY AS 급여, 
        ROUND(AVG(e.SALARY), 2) OVER(PARTITION BY d.DEPTNAME) AS 부서평균급여
            FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO) e1
    WHERE e1.SALARY > e1.부서평균급여;

--문제 8.
CREATE VIEW v_longest_serving AS
    SELECT e1.이름, e1.부서명, e1.입사일, e1.근속연수
        FROM(
            SELECT e.NAME AS 이름, d.DEPTNAME AS 부서명, e.EMP_DATE AS 입사일, 
                    (TO_CHAR(SYSDATE, 'yyyy') - TO_CHAR(e.EMP_DATE, 'yyyy')) AS 근속연수,
                RANK() OVER(PARTITION BY d.DEPTNAME ORDER BY e.EMP_DATE ASC) as rank_01
            FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO) e1
    WHERE rank_01 = 1

--문제 9.
CREATE VIEW v_active_emp AS
    SELECT e.NAME AS 이름, COUNT(w.PROJNO) AS 프로젝트수, SUM(w.HOURS_WORKED) AS 총투입시간
        FROM WORKS w JOIN EMPLOYEE e ON w.EMPNO = e.EMPNO
    GROUP BY e.EMPNO, e.NAME
        HAVING COUNT(w.PROJNO) >= 2 and SUM(w.HOURS_WORKED) >= 100;

--문제 10.
CREATE VIEW v_dept_pm_stats AS
    SELECT d.DEPTNAME AS 부서명, COUNT(CASE WHEN w.ROLE = 'PM' THEN 1 END) AS PM수,
        AVG(e.SALARY) AS 부서평균급여
    FROM EMPLOYEE e JOIN DEPARTMENT d ON e.DEPTNO = d.DEPTNO
        LEFT JOIN WORKS w ON e.EMPNO = w.EMPNO
    GROUP BY d.DEPTNAME;
