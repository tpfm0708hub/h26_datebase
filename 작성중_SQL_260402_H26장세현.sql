--문제 20
--제약조건
--영화가격은 20,000원을 넘지 않아야 한다.
--상영관번호는 1~10사이다
--같은 사람이 같은 좌석번호를 두 번 예약하지 않아야 한다.

alter table 상영관 add constraint 가격 check (가격=<20000);
alter table 상영관 add constraint 상영관번호 check (상영관번호<11 and 상영관번호>0);
alter table 예약 add constraint 좌석번호 unique (고객번호, 좌석번호);

--(1)단순질의
--①모든 극장의 이름과 위치를 보이시오
--②‘잠실’에 있는 극장을 보이시오
--③‘잠실’에 사는 고객의 이름을 오름차순으로 보이시오
--④가격이 8,000원 이하인 영화의 극장번호,영화제목을 보이시오
--⑤극장 위치와 고객의 주소가 같은 고객을 보이시오

--①
select c.극장이름, c.위치 from 극장 c;
--②
update 극장 set 위치 = '잠실' where 위치 = '송파';
select * from 극장 where 위치 = '잠실';
--③
select distinct p.이름 from 고객 p where p.주소 = '잠실' order by 이름;
--④
select t.극장번호, t.영화제목 from 상영관 t where t.가격 <= 8000;
--⑤
select distinct p.이름 from 고객 p join 예약 r on r.고객번호 = p.고객번호 join 극장 c on r.극장번호 = c.극장번호 where p.주소 = c.위치;

--(2)집계질의
--①극장의 수는 몇 개인가?
--②상영되는 영화의 평균 가격은 얼마인가?
--③2025년 9월 1일에 영화를 관람한 고객의 수는 얼마인가?

--①
select count(*) as cnt from 극장;
--②
select avg(가격) as 평균가 from 상영관;
--③
select count(고객번호) from 예약 where 날짜 = to_date('2025-9-1','YYYY-MM-DD');

--(3)부속질의와 조인
--①‘대한’극장에서 상영된 영화 제목을 보이시오
--②‘대한’극장에서 영화를 본 고객의 이름을 보이시오
--③‘대한 극장의 전체 수입을 보이시오

--①
select t.영화제목 from 상영관 t where t.극장번호 in (selectg c.극장번호 from 극장 c where c.극장이름 = '대한');
--②
select distinct p.이름 from 예약 r join 극장 c on r.극장번호 = c.극장번호 join 고객 p on r.고객번호 = p.고객번호 where c.극장이름='대한';
--③
select sum(t.가격) as 전체수입 from 극장 c join 상영관 t on c.극장번호 = t.극장번호 where c.극장이름 = '대한';

--(4)그룹질의
--①극장별 상영관 수를 보이시오
--②‘잠실’에 있는 극장의 상영관을 보이시오
--③2025년 9월 1일의 극장별 평균 관람 고객 수를 보이시오
--④2025년 9월 1일에 가장 많은 고객이 관람한 영화를 보이시오

--①
select c.극장번호,count(t.상영관번호) as cnt_01 from 상영관 t group by t.극장번호;
--②
select t.* from 상영관 t join 극장 c on t.극장번호 = c.극장번호 where c.위치 = '잠실';
--③
select r.극장번호, count(r.고객번호) as cnt_01 from 예약 r where 날짜 = to_date('2025-9-1','YYYY-MM-DD') group by r.극장번호;
--④
select t1.영화제목 from 예약 r1 join 상영관 t1 on r1.상영관번호 =  t1.상영관번호 join 극장 c1 on r1.극장번호 = c1.극장번호
 where 날짜 = to_date('2024-10-1','YYYY-MM-DD') group by t1.영화제목 having count(t1.영화제목) = 
(select max(count(r.고객번호)) from 예약 r join 상영관 t on r.상영관번호 = t.상영관번호 where 날짜 = to_date('2024-10-1','YYYY-MM-DD') group by t.영화제목);

--(5)DML
--①각 테이블에 데이터를 삽입하는 INSERTans을 하나씩 실행시켜 보시오.
--②영화의 가격을 10%씩 인상하시오
--①
insert into 극장 values(6,'CGV','야탑');
insert into 고객 values (9,'김갑수', '야탑');
insert into 상영관 values(6,1,'과속스캔들',8000,10);
insert into 예약 values(6,1,9,9,'2026-4-3');
--②
update 상영관 set 가격 = 가격 * 1.1;

--문제 21
--(1)테이블을 생성하는 CREATE 문과 데이터를 삽입하는 INSERT문을 작성하시오.
--테이블의 데이터 타입은 임의로 정하고, 데이터는 다음 질의의 결과가 나오도록
--삽입한다.
--(2)모든 판매원의 이름과 급여를 보이시오. 단 중복 행은 제거한다.
--(3)나이가 30세 미만인 판매원의 이름을 보이시오.
--(4)‘S’로 끝나는 도시에 사는 고객의 이름을 보이시오.
--(5)주문을 한 고객의 수(서로 다른 고객만)를 구하시오.
--(6)판매원 각각에 대하여 주문의 수를 계산하시오.
--(7)‘LA’에 사는 고객으로부터 주문을 받은 판매원의 이름과 나이를 보이시오.(부속질의 사용)
--(8)‘LA’에 사는 고객으로부터 주문을 받은 판매원의 이름과 나이를 보이시오.(조인사용)
--(9)두 번 이상 주문을 받은 판매원의 이름을 보이시오.
--(10)판매원 ‘TOM’의 봉급을 45,000원으로 변경하는 sql문을 작성하시오

--(1)
create table salesperson_0402(
name varchar2(20) Primary key,
age number not null,
salary number);

create table customer_0402(
name varchar2(20) primary key,
city varchar2(20),
indiustrutype number);

create table order_0402(
number_0402 number,
custname varchar2(20),
salesperson varchar2(20),
amount number,
primary key(custname, salesperson),
constraint fk_order_cust_0402 foreign key(custname)
references customer_0402(name),
constraint fk_order_sale_0402 foreign key(salesperson)
references salesperson_0402(name));

insert into salesperson_0402 values('kim',28,280);
insert into salesperson_0402 values('lee',29,290);
insert into salesperson_0402 values('park',30,300);
insert into salesperson_0402 values('choi',31,310);
insert into salesperson_0402 values('jang',31,310);
insert into salesperson_0402 values('moon',30,300);
insert into salesperson_0402 values('cho',29,290);
insert into salesperson_0402 values('lim',28,280);

insert into customer_0402 values('kim','seongnam',1);
insert into customer_0402 values('lee','seongnam',2);
insert into customer_0402 values('park','seongnam',3);
insert into customer_0402 values('choi','seongnam',4);
insert into customer_0402 values('jang','LA',4);
insert into customer_0402 values('moon','LA',3);
insert into customer_0402 values('cho','LA',2);
insert into customer_0402 values('lim','LA',1);

insert into order_0402 values(1,'kim','kim',2);
insert into order_0402 values(2,'lee','kim',3);
insert into order_0402 values(3,'park','kim',3);
insert into order_0402 values(4,'choi','kim',2);
insert into order_0402 values(5,'jang','kim',4);
insert into order_0402 values(6,'moon','kim',3);
insert into order_0402 values(7,'cho','kim',3);
insert into order_0402 values(8,'lim','kim',4);

insert into order_0402 values(9,'moon','lee',3);
insert into order_0402 values(10,'cho','lee',3);
insert into order_0402 values(11,'lim','lee',4);

insert into order_0402 values(12,'lee','park',3);
insert into order_0402 values(13,'kim','park',4);

insert into order_0402 values(14,'jang','choi',3);
insert into order_0402 values(15,'lim','choi',3);
insert into order_0402 values(16,'cho','choi',4);

insert into order_0402 values(17,'park','jang',3);
insert into order_0402 values(18,'lee','jang',3);
insert into order_0402 values(19,'jang','jang',4);

insert into order_0402 values(20,'lee','moon',3);

--(2)
select s.name, s.salary from salesperson_0402 s;
--(3)
select s.name from salesperson_0402 s where s.age < 30;
--(4)
select c.name from customer_0402 c where c.name like '%s';
--(5)
select count(distinct o.custname) as cnt_01 from order_0402 o;
--(6)
select count(o.number_0402) as cnt_01 from order_0402 o group by salesperson;
--(7)
select distinct s1.name, s1.age from salesperson_0402 s1 join order_0402 o1 on s1.name = o1.salesperson where o1.custname in (
select c.name from customer_0402 c where city = 'LA');
--(8)
select distinct s.name, s.age from order_0402 o join salesperson_0402 s on o.salesperson = s.name join customer_0402 c on o.custname = c.name where c.city = 'LA';
--(9)
select o.salesperson from order_0402 o group by o.salesperson having count(o.salesperson) >= 2;
--(10)
update salesperson_0402 set salary = 45000 where name = 'TOM';

--문제 22
--[기업 프로젝트 데이터베이스]
--(1)테이블을 생성하는 CREATE문과 데이터를 삽입하는 INSERT문을 작성하시오.
--테이블의 데이터 타입은 임의로 정하고, 데이터는 다음 질의의 결과가 나오도록
--삽입한다.
--(2)모든 사원의 이름을 보이시오
--(3)여자 사원의 이름을 보이시오
--(4)팀장(manager)의 이름을 보이시오
--(5)‘IT’부서에서 일하는 사원의 이름과 주소를 보이시오
--(6)‘홍길동’ 팀장(manager)부서에서 일하는 사원의 수를 보이시오
--(7)사원들이 일한 시간 수를 부서별, 사원 이름별 오름차순으로 보이시오
--(8)2명 이상의 사원이 참여한 프로젝트의 번호, 이름, 사원의 수를 보이시오
--(9)3명 이상의 사원이 있는 부서의 사원 이름을 보이시오
--(1)
create table Employee_0403(
empno number Primary key,
name varchar2(20),
phoneno varchar2(30),
address varchar2(30),
sex number(1),
position number(1),
depno number(1)
);

create table Department_0403(
depno number Primary key,
deptname varchar2(30),
manager varchar2(20)
);

create table Project_0403(
projno number Primary key,
projname varchar2(20),
deptno number,
constraint fk_project_0403 foreign key (deptno)
references Department_0403(depno)
);

create table Works_0403(
empno number,
projno number,
hours_worked number,
Primary key(empno, projno),
constraint fk_works_emp_0403 foreign key(empno)
references Employee_0403(empno),
constraint fk_works_proj_0403 foreign key(projno)
references Project_0403(projno)
);

insert into employee_0403 values(1,'김길동',010-0000-0000,'경기도 성남시',1,1,1);
insert into employee_0403 values(2,'남이사',010-0000-0000,'서울시 송파구',1,2,1);
insert into employee_0403 values(3,'도라지',010-0000-0000,'경기도 성남시',2,2,1);
insert into employee_0403 values(4,'류미나',010-0000-0000,'서울시 송파구',2,2,1);
insert into employee_0403 values(5,'문우람',010-0000-0000,'경기도 성남시',1,1,2);
insert into employee_0403 values(6,'변희은',010-0000-0000,'서울시 송파구',2,2,2);
insert into employee_0403 values(7,'심밧드',010-0000-0000,'경기도 성남시',1,2,3);
insert into employee_0403 values(8,'임꺾정',010-0000-0000,'서울시 송파구',1,2,3);
insert into employee_0403 values(9,'정도희',010-0000-0000,'경기도 성남시',2,2,3);
insert into employee_0403 values(10,'홍길동',010-0000-0000,'서울시 송파구',1,1,3);

insert into department_0403 values(1, 'IT', '김길동');
insert into department_0403 values(2, '총무팀', '문우람');
insert into department_0403 values(3, '구매팀', '홍길동');

insert into project_0403 values(1,'프로젝트알파',1);
insert into project_0403 values(2,'프로젝트베타',1);
insert into project_0403 values(3,'프로젝트감마',2);
insert into project_0403 values(4,'프로젝트델타',2);
insert into project_0403 values(5,'프로젝트제로',3);

insert into works_0403 VALUES(1, 1, 40);
insert into works_0403 VALUES(1, 2, 20);
insert into works_0403 VALUES(2, 1, 35);
insert into works_0403 VALUES(3, 3, 45);
insert into works_0403 VALUES(4, 4, 30);
insert into works_0403 VALUES(5, 3, 25);
insert into works_0403 VALUES(6, 1, 15);
insert into works_0403 VALUES(6, 5, 10);
insert into works_0403 VALUES(7, 4, 50);
insert into works_0403 VALUES(8, 2, 40);
insert into works_0403 VALUES(9, 3, 20);
insert into works_0403 VALUES(10, 5, 30);

--(2)
select name from employee_0403;
--(3)
select name from employee_0403 where sex = 2;
--(4)
select distinct d.manager from works_0403 w join project_0403 p on w.projno = p.projno join department_0403 d on p.deptno = d.depno;
--(5)
select distinct e.name, e.address from works_0403 w join project_0403 p on w.projno = p.projno 
join department_0403 d on p.deptno = d.depno 
join employee_0403 e on w.empno = e.empno
where d.deptname = 'IT'
;
--(6)
select count(*) as cnt_01 from employee_0403 e1 where exists (
select 1 from department_0403 d 
where d.manager='홍길동' and d.depno = e1.depno)
;
--(7)
select sum(w3.hours_worked) from department_0403 d1 join employee_0403 e2 on d1.depno = e2.depno join works_0403 w3 on e2.empno = w3.empno 
group by d1.deptname, e2.name order by d1.deptname,e2.name;
--(8)
select p1.projno,p1.projname,count(w2.empno) as cnt_01 from project_0403 p1 join works_0403 w2 on p1.projno = w2.projno group by p1.projno,p1.projname having count(w2.empno) >=2;
--(9)
select distinct e2.name from employee_0403 e2 where e2.depno in (select e1.depno from employee_0403 e1 group by e1.depno having count(e1.empno) >= 3);

--문제 03 다음과 같은 심화 질문에 대한 SQL문을 작성하시오.
--(1)‘박지성’이 구매한 도서의 출판사와 같은 출판사의 도서를 구매한 고객의 이름을 구하시오.
select distinct c3.name from orders o3 join customer c3 on o3.custid = c3.custid join book b3 on o3.bookid = b3.bookid where b3.bookname in (
select b2.bookname from book b2 where b2.publisher in(
select b1.publisher from orders o1 join customer c1 on o1.custid = c1.custid join book b1 on o1.bookid = b1.bookid where c1.name = '박지성'));
--(2)두 개 이상의 서로 다른 출판사의 도서를 구매한 고객의 이름을 구하시오
select distinct c1.name from orders o1 join customer c1 on o1.custid = c1.custid join book b1 on o1.bookid = b1.bookid where b1.publisher in (
select b.publisher from book b group by b.publisher having (count(b.publisher) > 1));
--(3)전체 고객의 30% 이상이 구매한 도서를 검색하시오
select b1.bookname from book b1 where b1.bookid in (
select distinct o.bookid from orders o group by o.bookid having(count(o.custid)>count(*)*0.3));

--문제 04
--마당서점 데이터베이스에서 주문에 관한 사항은 Orders 테이블에 저장되어 있다. Order
--테이블을 사용하여 도서번호 (bookid) 가 1번인 책은 주문하였으나 2번과 3번 책은 주문
--하지 않은 깩의 아이디(custid)를 찾는 SQL문을 작성하시오
select o2.custid from orders o2 where o2.custid in
(select o.custid from orders o where o.bookid = 1
minus
select o1.custid from orders o1 where o1.bookid in (2, 3)
);

--문제 5. 다음 질의에 대해 DDL문과 DML문을 작성하시오.
--(1)새로운 도서(‘스포츠세계’, ‘대한미디어’, 10000원)을 Book테이블에 삽입하시오. 삽입이 안될 경우 필요한 데이터가 더 있는지 찾아보시오
INSERT INTO BOOK VALUES(11, '스포츠세계', '대한미디어', 10000);
--(2)출판사 ‘삼성당’에서 출간한 도서를 삭제하시오
delete from book where publisher = '삼성당';
--(3)출판사 ‘이상미디어’에서 출판한 도서를 삭제하시오. 삭제되지 않을 경우 그 원인을 설명하시오.
delete from book where publisher = '이상미디어';
    -- 무결성 제약조건 위반(orders에서 이상미디어 출간 책 3건 존재)
--(4)출판사 ‘대한미디어’를 ‘대한출판사’로 이름을 변경하시오
update book set publisher = '대한출판사' where publisher = '대한미디어';
--(5)출판사에 대한 정보를 저장하는 테이블 Bookcompany(name, address, begin)을 생성하시오. 
--name은 기본키(VARCHAR2(20)), address는 VARCHAR2(20), begin은 DATE타입으로 선언하여 생성하시오.
create table bookcompany(
 name varchar2(20) primary key,
 address varchar2(20),
 begin date
);
--(6)Bookcompany테이블에 인터넷 주소를 저장하는 webaddress 속성을 VARCHAR2(30)으로 추가하시오
alter table bookcompany add webaddress varchar2(30);
--(7)Bookcompany테이블에 임의의 튜플 name=한빛아카데미, address=서울시 마포구 ,begin=1993-01-01, webaddress는 http://hanbit.co.kr을 삽입하시오.
insert into passenger(name, address, begin, webaddress) values ('한빛아카데미','서울시 마포구',to_date('1993-01-01'. 'YYYY-MM-DD'),'http://hanbit.co.kr');
--문제 7.릴레이션 R(A,B,C), S(C,D,E)가 주어졌을 때 다음 관계대수를 같은 의미를 갖는SQL문으로 변환하시오
--(1) σA=a2(R)
SELECT * FROM R WHERE A = 'a2';
--(2)πA,B(R)
SELECT DISTINCT A, B FROM R;
--(3)R⋈R.c=S.c S
SELECT * FROM R INNER JOIN S ON R.c = S.c;

--문제 10. EXISTS와 NOT EXISTS 예제
select distinct c.name from customer c where exists (select 1 from orders o1 where o1.custid = c.custid);

--문제 17.
create table Cust_addr(
custid number,
addrid number,
address varchar2(20),
phone varchar2(20),
changedata Date,
primary key(custid,addrid),
constraint fk_cust_addr foreign key(custid)
references customer(custid));
--(1)고객번호 1번의 주소 변경 내역을 모두 조회하시오
select custid, address, changedate from cust_addr where custid=6;
--(2)고객번호 1번의 전화번호 변경 내역을 모두 조회하시오
select custid, phone, changedate from cust_addr where custid=6;
--(3)고객번호 1번의 가입 당시 전화번호를 조회하시오
select phone from (select phone from cust_addr where custid = 6 and changedate <= to_date('2025-01-01','YYYY-MM-DD')) where rownum = 1;

--문제 18.
--(1)고객번호 1번의 cart에 저장된 도서 중 이미 주문한 도서를 구하시오
select * from cart t where t.custid in (select o.bookid from orders o where o.custid = 1 and t.custid = 1);
--(2)고객번호 1번의 cart에 저장된 도서 중 아직 주문하지 않은 도서를 구하시오
select * from cart t where bookid in 
(select o1.bookid from orders o1
minus
select o.bookid from orders o where o.custid = 1);
--(3)고객번호 1번의 cart에 저장된 도서들의 정가 합계를 구하시오.
select sum(b.price) as 합계 from cart t join book b on t.bookid = b.bookid where t.custid = 1;

--문제 19
--(1)
create table Dept(
depno number(2) primary key,
dname varchar2(14),
loc varchar2(13));
--(2)
create table Emp(
empno number(4) Primary key,
ename varchar2(10),
job varchar2(9),
mgr number(4),
hiredate Date,
sal number(7,2),
comm number(7,2),
depno number(2),
constraint fk_emp_dept_new foreign key (depno)
references Dept(depno));
--(3)
insert into dept values (10, 'ACCOUNTING', "NEW YORK");
insert into dept values (20,'RESEARCH', 'DALLAS');
insert into dept values (30, 'SALES', 'CHICAGO');
insert into dept values (40, 'OPERATION', 'BOSTON');
--(4)
insert into emp values (7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, null, 20);
insert into emp values (7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300, 30);
insert into emp values (7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30);
insert into emp values (7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975, null, 20);
--(5): ‘1981-09-2800:00:00’ 입력시 to_date(일자, 'YYYY-MM-DD HH24:MI:SS')의 형식을 지정하지 않았습니다.
--(6)각 사원의 사원이름(ename)과 소속 부서이름(dname), 부서위치(loc)를 함께 조회하시오
select e.ename, d.dname, d.loc from emp e join dept d on e.depno = d.depno;
--(7) 부서가 배정된 사원의 사원번호(empno), 사원이름(ename), 부서이름(dname)을 조회하시오. 부서가 없는 사원은 제외한다.
select e.empno, e.ename, d.dname from emp e join dept d on e.depno = d.depno where d.dname is not null;
--(8) 부서 위치(loc)가 'DALLAS'인 부서에 소속된 모든 사원의 이름(ename), 업무(job), 월급여(sal)를 조회하시오.
select e.ename, e.job, e.sal from emp e join dept d on e.depno = d.depno where d.loc = 'DALLAS';
--(9)부서 위치(loc)가 'DALLAS'인 부서에 소속된 사원의 이름(ename), 업무(job)를 조회하시오. 서브쿼리를 사용할 것.
select e1.ename, e1.job, e1.sal from emp e1 join dept d1 on e1.depno = d1.depno where d1.depno in
(select d.depno from dept d where d.loc = 'DALLAS');
--(10)전체 사원의 평균 급여(AVG(sal))보다 급여가 높은 사원의 이름(ename)과 급여(sal)를 조회하시오.
select e.ename, e.sal from emp e where sal > (select avg(e1.sal) from emp e1);
--(11)각 사원의 이름(ename)과 그 사원의 직속상사 이름을 함께 조회하시오. 상사가 없는 사원도 포함할 것.
select e1.ename, e2.ename from emp e1 join emp e2 on e1.mgr = e2.empno;
--(12)각 부서에서 급여가 가장 높은 사원의 이름(ename), 급여(sal), 부서이름(dname)을 조회하시오. 조인과 서브쿼리를 함께 사용할 것.
select e1.ename, e1.sal, d1.dname from emp e1 join dept d1 on e1.depno = d1.depno where e1.sal = (select max(e2.sal) from emp e2 where e2.depno = e1.depno);
--(13)부서 테이블의 구조를 변경하여 부서장의 이름을 저장하는 manager속성을 추가하고자 한다. 
--    ALTER 문을 사용하여 작성해 보시오. managername 속성이 만들어졌으면UPDATE문을 이용하여 MANAGER의 이름을 입력하시오.
alter table dept add managername.varchar2(14);
update dept d2
set d2.managername = (
select distinct e2.ename
from emp e2
where e2.depno = d2.depno
and e2.empno in (select mgr from emp))
where d2.depno in (select distinct e1.depno from emp e1 where 
e1.empno in (select e2.mgr from emp e2));
