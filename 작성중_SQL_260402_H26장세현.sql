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
