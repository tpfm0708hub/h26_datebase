--문제23

--(1)교재 질의
--⓵사원의 이름과 업무를 출력하시오. 단 사원의 이름은 ‘사원이름’, ‘업무는 ’사원업무‘, 머리글이 나오도록 출력하시오.
--⓶30번 부서에 근무하는 모든 사원의 이름과 급여를 출력하시오
--⓷사원번호와 이름, 현재급여, 증가된 급여분(열 이름은 증가액), 10% 인상된 급여(열 이름은’인상된 급여‘)를 사원 번호 순으로 출력하시오.
--⓸’S’로 시작하는 모든 사원과 부서번호를 출력하시오.
--⑤모든 사원의 최대 및 최소 급여, 합계 및 평균 급여를 출력하시오. 열이름은 각각 MAX,MIN, SUM, AVG로 한다. 단 소수점 이하는 반올림하여 정수로 출력한다.
--⓺업무(job)별로 동일한 업무를 하는 사원의 수를 출력하시오. 열이름은 각각 ‘업무’ 와 ‘업무별 사원수’로 한다.
--⓻사원의 최대 급여와 최소 급여의 차액을 출력하시오.
--⓼30번 부서의 사원 수와 사원들 급여의 합계와 평균을 출력하시오.
--⓽평균 급여가 가장 높은 부서의 번호를 출력하시오.
--⓾세일즈맨(SALESMAN)을 제외하고, 각 업무별 사원의 총급여가 3,000이상인 가가 업무에 대해서, 업무명과 각 업무별 평균 급여를 출력하시오.
--⑪전체 사원 가운데 직속상관이 있는 사원의 수를 출력하시오.
--⑫EMP 테이블에서 이름, 급여, 커미션 금액(comm), 총액(sal*12+comm)을 구하여 총액이 많은 순서대로 출력하시오.
--⑬부서별로 같은 업무를 하는 사람의 인원수를 구하여 부서번호, 업무 이름, 인원수를 출력하시오.
--⑭사원이 한 명도 없는 부서의 이름을 출력하시오.
--⑮같은 업무를 하는 사람의 수가 4명 이상인 업무와 인원수를 출력하시오.
--⑯사원번호가 7400 이상 7600 이하인 사원의 이름을 출력하시오.
--⑰사원의 이름과 사원의 부서이름을 출력하시오.
--⑱사원의 이름과 팀장(mgr)의 이름을 출력하시오.
--⑲사원 SCOTT보다 급여를 많이 받는 사람의 이름을 출력하시오.
--⑳사원 SCOTT이 일하는 부서번호 혹은 DALLAS 에 있는 부서번호를 출력하시오

--⓵
select distinct e.ename as 사원이름, e.job as 사원업무 
    from emp e;
--⓶
SELECT DISTINCT e.ENAME as 사원이름, e.SAL as 급여 
    FROM EMP e where e.DEPTNO = 30 ORDER BY e.SAL desc;
--⓷
SELECT DISTINCT e.EMPNO as 사원번호, e.ENAME as 사원이름, 
    e.SAL as 급여, (e.SAL * 1.1) as 증가된급여, (e.SAL * 0.1) as 인상된급여 FROM EMP e ORDER BY e.EMPNO;
--⓸
SELECT DISTINCT e.ENAME, e.DEPTNO FROM EMP e 
    where e.ENAME like 'S%';
--⑤
SELECT MAX(e.SAL) as MAX, MIN(e.SAL) as MIN, SUM(e.SAL) as SUM, 
    ROUND(AVG(e.SAL),2) as AVG FROM EMP e;
--⓺
SELECT e.JOB as 업무, COUNT(DISTINCT e.EMPNO) as 업무별사원수 
    FROM EMP e GROUP BY e.JOB;
--⓻
SELECT MAX(e.SAL)-MIN(e.SAL) as 차액 FROM EMP e;
--⓼
SELECT COUNT(DISTINCT e.EMPNO) as 사원수, SUM(e.SAL) as 급여합계,
    ROUND(AVG(e.SAL), 0) as 급여평균 from EMP e WHERE e.DEPTNO = 30;
--⓽
SELECT e.DEPTNO FROM EMP e GROUP BY e.DEPTNO 
    HAVING AVG(e.SAL) = (SELECT MAX(AVG(e1.SAL))
FROM EMP e1 GROUP BY DEPTNO);
--⓾
SELECT e.JOB, ROUND(AVG(e.SAL), 2) as 평균급여 FROM EMP e
    WHERE e.JOB != 'SALESMAN' GROUP BY e.JOB HAVING 평균급여 >= 3000;
--⑪
SELECT COUNT(DISTINCT e.EMPNO) as 직속상관있음 FROM EMP e WHERE e.MGR IS NOT NULL;
--⑫
SELECT DISTINCT e.ENAME as 이름, e.SAL as 급여, e.COMM as 커미션금액, ((e.SAL * 12) + NVL(e.COMM,0)) as 총액
FROM EMP e ORDER BY 총액 desc;
--⑬
SELECT e.DEPTNO as 부서번호, e.JOB as 업무, COUNT(*) as 인원수 FROM EMP e GROUP BY e.DEPTNO, e.JOB;
--⑭
SELECT d1.DNAME FROM DEPT d1 where d1.DEPTNO not in (
    SELECT e.DEPTNO FROM EMP e GROUP BY e.DEPTNO);
--⑮
SELECT e.JOB, COUNT(e.JOB) as 인원수 FROM EMP e GROUP BY e.JOB HAVING COUNT(e.JOB) >= 4;
--⑯
SELECT e.ENAME from EMP e WHERE e.EMPNO between 7400 and 7600;
--⑰
SELECT e.ENAME, d.DNAME FROM EMP e LEFT JOIN DEPT d on e.DEPTNO = d.DEPTNO;
--⑱
SELECT e.ENAME as 사원명, e1.ENAME as 관리자명
    FROM EMP e LEFT JOIN EMP e1 on e.MGR = e1.EMPNO;
--⑲
SELECT e.ENAME FROM EMP e WHERE e.SAL > (
    SELECT e1.SAL FROM EMP e1 WHERE e1.ENAME = 'SCOTT');
--⑳
SELECT d.DEPTNO FROM DEPT d WHERE d.DEPTNO in (
    SELECT e1.DEPTNO from EMP e1 WHERE e1.ENAME = 'SCOTT') or 
    d.DEPTNO in (
    SELECT d1.DEPTNO FROM DEPT d1 WHERE LOC = 'DALLAS'
    );

--(2)단순질의
--⓵comm(커미션)이 NULL이 아닌 사원의 이름과 커미션을 출력하시오.
--⓶급여가 1500이상 3000 이하인 사원의 이름과 급여를 급여 오름차순으로 출력하시오.
--⓷1981년에 입사한 사원의 이름과 입사일을 출력하시오.
--⓸이름의 세 번째 글자가 ‘A’인 사원을 출력하시오.
--⑤사원의 이름을 소문자로 출력하시오.
--⓺사원 이름, 입사일, 오늘까지의 근무 개월 수를 출력하시오.
--⓻사원 이름과 이름의 글자 수를 글자 수 내림차순으로 출력하시오.
--⓼comm이 NULL이면 0으로 대체하여 총소득(sal+comm)을 출력하시오.
--⓽ANALYST 또는 PRESIDENT인 사원의 이름, 업무, 급여를 출력하시오.
--⓾이름 길이가 긴 순, 같으면 알파벳 순으로 사원 이름을 출력하시오.

--⓵
SELECT e.ENAME as 사원명, e.COMM as 커미션금액  FROM EMP e WHERE COMM IS NOT NULL;
--⓶
SELECT e.ENAME as 사원명, e.SAL as 급여 FROM EMP e WHERE e.SAL BETWEEN 1500 and 3000 ORDER BY e.SAL;
--⓷
SELECT e.ENAME as 사원명, e.HIREDATE as 입사일 FROM EMP e WHERE TO_CHAR(e.HIREDATE, 'YYYY') = '1981';
--⓸
SELECT * as 사원명 from EMP e WHERE e.ENAME like '%A';
--⑤
SELECT LOWER(e.ENAME) FROM EMP e;
--⓺
SELECT e.ENAME, e.HIREDATE, round((TO_DATE(SYSDATE, 'YY-MM-DD')-e.HIREDATE)/30, 2) as 근무개월수 FROM EMP e;
--⓻
SELECT e.ENAME, LENGTH(e.ENAME) as 이름글자수 FROM EMP e
--⓼
SELECT SUM(e.SAL + NVL(e.COMM, 0)) as 총소득 FROM EMP e;
--⓽
SELECT e.ENAME, e.JOB, e.SAL FROM EMP e WHERE e.JOB = 'ANALYST' or e.JOB = 'PRESIDENT';
--⓾
SELECT e.ENAME FROM EMP e ORDER BY LENGTH(e.ENAME), e.ENAME;

--(3)부속질의
--⓵JONES와 같은 부서에 근무하는 사원의 이름을 출력하시오(JONES본인 제외)
--⓶각 부서에서 가장 높은 급여를 받는 사원의 이름, 급여, 부서번호를 출력하시오.
--⓷30번 부서 평균 급여보다 급여가 높은 사원의 이름과 급여를 출력하시오.
--⓸MANAGER 직급 평균 급여보다 적은 CLERK 사원의 이름과 급여를 출력하시오.
--⑤업무별 최고 급여를 받는 사원의 이름, 업무, 급여를 출력하시오.
--⓺KING에게 직접 보고하는 사원의 이름과 업무를 출력하시오.
--⓻입사일이 가장 최근인 사원과 가장 오래된 사원을 함께 출력하시오.
--⓼전체 평균 급여보다 급여가 높고 직위가 MANAGER인 사원을 출력하시오.
--⓽급여가 전체 사원 급여 합계의 10%를 초과하는 사원이 이름과 급여를 출력하시오.
--⓾BLAKE와 같은 직위(job)를 가진 사원의 이름과 급여를 출력하시오(BLAKE 본인 제외)
--⑪30번 부서에 속한 사원과 같은 직위(job)를 가진 모든 사원을 출력하시오.
--⑫급여가 모든 CLERK보다 많은 사원의 이름과 급여를 출력하시오(ALL)
--⑬SALESMAN 중 누구보다도 급여가 많은 사원의 이름과 급여를 출력하시오.(ANY)
--⑭부하 직원이 존재하는 (관리자인) 사원의 이름과 직위를 출력하시오(EXITS)
--⑮급여 상위 3위 안에 드는 사원의 이름과 급여를 출력하시오.

--⓵
SELECT e.ENAME as 이름 FROM EMP e WHERE e.DEPTNO in (
    SELECT e1.DEPTNO FROM EMP e1 WHERE ENAME = 'JONES') 
and e.ENAME != 'JONES';
--⓶
SELECT e.ENAME as 이름, e.SAL as 급여, e.DEPTNO as 부서번호 FROM EMP e 
    JOIN (SELECT DEPTNO, MAX(SAL) as 총급여 FROM EMP GROUP BY DEPTNO) e1
ON e.DEPTNO = e1.DEPTNO and e.SAL = e1.총급여;
--⓷
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e WHERE e.SAL > (
    SELECT AVG(e1.SAL) FROM EMP e1 WHERE e1.DEPTNO = 30);
--⓸
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e WHERE e.JOB = 'CLERK' and
    e.SAL < (SELECT AVG(e1.SAL) FROM EMP e1 WHERE e1.JOB = 'MANAGER');
--⑤
SELECT e.ENAME as 이름, e.JOB as 업무, e.SAL as 급여 FROM EMP e 
    JOIN (SELECT JOB, MAX(SAL) as 최대급여 FROM EMP GROUP BY JOB) e1
ON e.JOB = e1.JOB and e.SAL = e1.최대급여;
--⓺
SELECT e.ENAME as 이름, e.JOB as 업무 FROM EMP e WHERE e.MGR = (
SELECT e1.EMPNO FROM EMP e1 WHERE e1.ENAME = 'KING'
);
--⓻
SELECT * FROM EMP e where e.HIREDATE = (
    SELECT MIN(HIREDATE) FROM EMP) or e.HIREDATE = (
    SELECT MAX(HIREDATE) FROM EMP);
--⓼
SELECT * FROM EMP e WHERE e.SAL > (
    SELECT AVG(e1.SAL) FROM EMP e1) and e.JOB = 'MANAGER';
--⓽
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e WHERE e.SAL > (
    SELECT SUM(e1.SAL)*0.1 FROM EMP e1);
--⓾
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e 
    WHERE e.JOB = (SELECT e1.JOB FROM EMP e1 
    WHERE e1.ENAME = 'BLAKE') and e.ENAME != 'BLAKE';
--⑪
SELECT * FROM EMP e WHERE e.JOB in (
    SELECT e1.JOB FROM EMP e1 WHERE e1.DEPTNO = 30);
--⑫
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e WHERE e.SAL > all(
    SELECT e1.SAL FROM EMP e1 WHERE e1.JOB='CLERK');
--⑬
SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e WHERE e.SAL = any(
    SELECT e1.SAL FROM EMP e1) and e.JOB = 'SALESMAN';
--⑭
SELECT e.ENAME as 이름, e.JOB as 직위 FROM EMP e WHERE EXISTS (
    SELECT 1 FROM emp e1 WHERE e1.MGR = e.EMPNO);
--⑮
SELECT * FROM (SELECT e.ENAME as 이름, e.SAL as 급여 FROM EMP e ORDER BY 급여 DESC) WHERE ROWNUM <= 3;

--(4)조인질의
--⓵사원의 이름과 소속 부서 이름을 출력하시오.
--⓶사원의 이름과 팀장의 이름을 출력하시오.(셀프 조인)
--⓷사원이 한 명도 없는 부서의 이름을 출력하시오.
--⓸NEW YORK에 근무하는 사원의 이름과 업무를 출력하시오.
--⑤사원이름, 급여, 급여 등급을 출력하시오.(SALGRADE 활용)
--⓺사원이름, 급여, 급여 등급, 부서 이름을 한 번에 출력하시오.
--⓻자신의 상관보다 급여가 높은 사원의 이름과 두 사람의 급여를 출력하시오.
--⓼사원 이름, 부서이름, 근무 도시를 출력하시오.
--⓽CHOICAGO에 근무하는 사원 수를 출력하시오.
--⓾부서별 인원 수가 많은 순으로 부서번호, 부서이름, 인원수를 출력하시오.
--⑪부서별 평균 급여를 부서이름과 함께 출력하시오.
--⑫급여 등급이 3등급인 사원의 이름, 급여, 부서이름을 출력하시오.
--⑬사원의 이음, 입사일, 입사 요일을 부서이름과 함께 출력하시오.
--⑭같은 부서에서 근무하는 사원끼리 이름을 나란히 출력하시오.(셀프 조인, 중복제거)
--⑮사원이름, 상관이름, 상관의 부서이름을 출력하시오(셀프+DEPTt조인)

--⓵
SELECT DISTINCT e.ENAME as 이름, d.DNAME as 부서이름 FROM EMP e 
    JOIN DEPT d ON e.DEPTNO = d.DEPTNO;
--⓶
SELECT DISTINCT e.ENAME as 사원이름, e1.ENAME as 팀장이름 FROM EMP e 
    JOIN EMP e1 ON e.MGR = e1.EMPNO;
--⓷
SELECT d.DNAME as 부서명 FROM DEPT d 
    LEFT JOIN EMP e ON d.DEPTNO = e.DEPTNO
WHERE e.DEPTNO IS NULL;
--⓸
SELECT e.ENAME as 사원이름, e.JOB as 업무 FROM DEPT d 
    LEFT JOIN EMP e ON d.DEPTNO = e.DEPTNO 
where LOC = 'NEW YORK';
--⑤
SELECT e.ENAME as 사원이름, e.SAL as 급여, s.GRADE as 급여등급 FROM EMP e 
    JOIN SALGRADE s ON e.SAL BETWEEN s.LOSAL and s.HISAL;
--⓺
SELECT e.ENAME as 사원이름, e.SAL as 급여, s.GRADE as 급여등급, d.DNAME as 부서이름 
    FROM EMP e JOIN SALGRADE s ON e.SAL BETWEEN s.LOSAL and s.HISAL 
JOIN DEPT d ON e.DEPTNO = d.DEPTNO;
--⓻
SELECT e.ENAME as 사원이름, e.SAL as 급여, e1.SAL as 준거급여 FROM EMP e 
    LEFT JOIN EMP e1 ON e.MGR = e1.EMPNO 
WHERE e.SAL > e1.SAL;
--⓼
SELECT e.ENAME as 사원이름, d.DNAME as 부서이름, d.LOC as 근무도시 FROM EMP e
    JOIN DEPT d ON e.DEPTNO = d.DEPTNO;
--⓽
SELECT COUNT(DISTINCT e.EMPNO) as 사원수 FROM EMP e 
    JOIN DEPT d ON e.DEPTNO = d.DEPTNO
WHERE d.LOC = 'CHICAGO';
--⓾
SELECT d.DEPTNO as 부서번호, d.DNAME as 부서이름, COUNT(DISTINCT e.EMPNO) as 인원수 FROM EMP e
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO
GROUP BY d.DEPTNO, d.DNAME ORDER BY 인원수 DESC;
--⑪
SELECT d.DNAME as 부서이름, ROUND(AVG(e.SAL), 2) as 평균급여 FROM EMP e 
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO
GROUP BY 부서이름;
--⑫
SELECT e.ENAME as 사원이름, e.SAL as 급여, d.DNAME FROM EMP e
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO
LEFT JOIN SALGRADE s ON e.SAL BETWEEN s.LOSAL and s.HISAL
    WHERE s.GRADE = 3;
--⑬
SELECT e.ENAME as 사원이름, e.HIREDATE as 입사일, TO_CHAR(e.HIREDATE, 'day') as 입사요일, d.DNAME FROM EMP e
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO;
--⑭
SELECT e.DEPTNO as 부서번호, LISTAGG(e.ENAME, ', ') WITHIN GROUP (ORDER BY e.ENAME) as 부서원들 FROM EMP e
    GROUP BY DEPTNO;

SELECT e.ENAME as 사원1, e1.ENAME as 사원2, e.DEPTNO as 부서번호 FROM EMP e
    LEFT JOIN EMP e1 ON e.DEPTNO = e1.DEPTNO
WHERE e.EMPNO < e1.EMPNO ORDER BY e.DEPTNO;
--⑮
SELECT e.ENAME as 사원이름, e1.ENAME as 상관이름, d1.DNAME as 상관부서이름 FROM EMP e
    LEFT JOIN EMP e1 ON e.MGR = e1.EMPNO
LEFT JOIN DEPT d1 ON e1.DEPTNO = d1.DEPTNO;

--(5)집계질의
--⓵업무별 최고, 최소, 평균 급여와 사원 수를 출력하시오.
--⓶부서별, 업무별 인원수를 출력하시오.
--⓷직원별 총 급여(sal*12+comm)를 내림차순으로 출력하시오.
--⓸평균 급여보다 높은 급여를 받는 부서(번호)와 해당 부서의 평균 급여를 출력하시오
--⑤입사년도별 사원 수를 출력하시오.
--⓺급여 등급별 사원 수와 평균 급여를 출력하시오
--⓻총급여가 5000 이상인 부서의 번호와 합계를 출력하시오.
--⓼각 사원의 급여가 전체 급여 합계에서 차지하는 비율(%)을 출력하시오.
--⓽근속 연수 10년 이상인 사원의 이름, 입사일, 근속 연수를 출력하시오.
--⓾급여 상위 5명의 사원 이름과 급여를 출력하시오

--⓵
SELECT e.JOB as 업무, MAX(e.SAL) as 최대급여, MIN(e.SAL) as 최소급여, ROUND(AVG(e.SAL),2) as 평균급여, COUNT(DISTINCT e.EMPNO) as 사우너수
    FROM EMP e GROUP BY e.job;
--⓶
SELECT d.DNAME as 부서, e.JOB as 업무, COUNT(e.EMPNO) as 사원수 FROM EMP e 
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO
GROUP BY d.DNAME, e.JOB;
--⓷
SELECT e.ENAME as 직원, SUM(sal*12+NVL(e.SAL, 0)) as 총급여 FROM EMP e
    GROUP BY e.ENAME ORDER BY 총급여 DESC;
--⓸
SELECT e.DEPTNO as 부서번호, ROUND(AVG(e.SAL), 2) as 평균급여 FROM EMP e
    GROUP BY e.DEPTNO HAVING AVG(e.SAL) > (SELECT AVG(e1.SAL) FROM EMP e1);
--⑤
SELECT TO_CHAR(e.HIREDATE, 'YYYY') as 입사년도, COUNT(EMPNO) as 사원수 FROM EMP e
    GROUP BY 입사년도;
--⓺
SELECT s.GRADE as 급여등급, COUNT(e.EMPNO) as 사원수 FROM EMP e
    LEFT JOIN SALGRADE s ON e.SAL BETWEEN s.LOSAL and s.HISAL
GROUP BY 급여등급;
--⓻
SELECT d.DEPTNO as 부서번호, SUM(e.SAL) as 합계 FROM EMP e
    LEFT JOIN DEPT d ON e.DEPTNO = d.DEPTNO
GROUP BY 부서번호 HAVING 합계 > 5000;
--⓼
SELECT e.ENAME as 사원, ROUND(e.SAL/(SELECT SUM(e1.SAL) FROM EMP e1) * 100, 2) || '%' as 비율 FROM EMP e
    GROUP BY e.ENAME, e.SAL;
--⓽
SELECT e.ENAME, e.HIREDATE, TO_CHAR(SYSDATE,'YYYY') - TO_CHAR(e.HIREDATE,'YYYY') as 근속년수 FROM EMP e
    GROUP BY e.ENAME, e.HIREDATE HAVING 근속년수 > 10;
--⓾
SELECT e1.ENAME, e1.SAL FROM 
    (SELECT e.ENAME, e.SAL FROM EMP e ORDER BY e.SAL DESC) e1
WHERE ROWNUM <= 5;
 
--문제24
--(1)교재 질의
--⓵Employees와 Departments테이블에 저장된 튜프의 개수를 출력하시오.
--⓶Employees테이블에 대한 employee_id, job_id, hire_date,를 출력하시오.
--⓷Employees테이블에서 salary가 12,000이상인 last_name과 salary를 출력하시오.
--⓸부서번호(department_id)가 20 혹은 50인 직원의 last_name과 department_id를 last_name에 대하여 오름차순으로 출력하시오.
--⑤last_name의 세 번째에 a가 들어가는 직원의 last_name을 출력하시오.
--⓺같은 일(job)을 하는 사람의 수를 세어 출력하시오
--⓻급여(salary)의 최대값과 최소값의 차이를 구하시오.
--⓼Toronto에서 일하는 직원의 last_name, job,department_id,Department_name을 출력하시오.

--⓵
SELECT 'EMPLOYEES' as 구분, COUNT(*) as 튜플개수 FROM EMPLOYEES
UNION ALL
SELECT 'DEPARTMENTS' as 구분, COUNT(*) as 튜플개수 FROM DEPARTMENTS;
--⓶
SELECT e.EMPLOYEE_ID, e.JOB_ID, e.HIRE_DATE FROM EMPLOYEES e;
--⓷
SELECT e.LAST_NAME, e.SALARY FROM EMPLOYEES e WHERE e.SALARY >= 12000;
--⓸
SELECT e.LAST_NAME, e.DEPARTMENT_ID FROM EMPLOYEES e WHERE DEPARTMENT_ID IN (20, 50) ORDER BY e.LAST_NAME DESC;
--⑤
SELECT e.LAST_NAME FROM EMPLOYEES e WHERE SUBSTR(e.LAST_NAME,3,1)='a';
SELECT e.LAST_NAME FROM EMPLOYEES e WHERE e.LAST_NAME LIKE '__a%';
--⓺
SELECT e.JOB_ID, COUNT(e.EMPLOYEE_ID) as 사람수 FROM EMPLOYEES e GROUP BY e.JOB_ID;
--⓻
SELECT MAX(e.SALARY) - MIN(e.SALARY) as 최소최대차 FROM EMPLOYEES e;
--⓼
SELECT e.LAST_NAME, e.JOB_ID, e.DEPARTMENT_ID, DEPARTMENT_NAME FROM EMPLOYEES e
    LEFT JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
WHERE EXISTS (SELECT 1 FROM LOCATIONS l WHERE l.LOCATION_ID = d.LOCATION_ID AND l.CITY = 'Toronto');  

--(2)부속질의
--⓵전체 직원 평균 급여보다 많이 받는 직원의 last_name과 salary를 출력하시오
--⓶dea hann과 같은 job_id를 가진 직원의 last_name과 job_id를 출력하시오.
--⓷부서별 최고 급여를 받는 직원의 last_name, department_id를 출력하시오.
--⓸IT부서 직원의 평균 급여보다 많이 받는 직원의 last_name과 salary를 출력하시오.
--⑤직무이력(JOB_HISTORY)이 있는 직원의 last_name과 현재 job_id를 출력하시오.
--⓺직무이력이 없는 직원의 last_name과 employee_id를 출력하시오.
--⓻급여가 자신이 속한 부서 평균보다 높은 직원의 이름,급여,부서번호를 출력하시오(상관부속질의)
--⓼kochhar(101)를 관리자로 두는 직원의 이름과 급여를 출력하시오.
--⓽급여 최상위 3명의 last_name과 salary를 출력하시오.
--⓾FI_ACCOUNT 직원 중 급여가 FI_ACCOUNT 평균보다 높은 직원을 출력하시오.

--⓵
SELECT e.LAST_NAME, e.SALARY FROM EMPLOYEES e WHERE e.SALARY > (
    SELECT AVG(e1.SALARY) FROM EMPLOYEES e1);
--⓶
SELECT e.LAST_NAME, e.JOB_ID FROM EMPLOYEES e WHERE e.JOB_ID = (
    SELECT e1.JOB_ID FROM EMPLOYEES e1 WHERE e1.LAST_NAME = 'dea_hann'
);
--⓷
SELECT e.LAST_NAME, e.DEPARTMENT_ID FROM EMPLOYEES e WHERE e.SALARY = (
    SELECT MAX(e1.SALARY) FROM EMPLOYEES e1 WHERE e.DEPARTMENT_ID = e1.DEPARTMENT_ID
) ORDER BY DEPARTMENT_ID;
--⓸
SELECT e.LAST_NAME, e.SALARY FROM EMPLOYEEs e WHERE e.SALARY > (
    SELECT AVG(e1.SALARY) FROM EMPLOYEES e1 WHERE e1.DEPARTMENT_ID = (
SELECT d1.DEPARTMENT_ID FROM DEPARTMENTS d1 WHERE DEPARTMENT_NAME = 'IT'
));
--⑤
SELECT e.LAST_NAME, e.JOB_ID FROM EMPLOYEES e
    LEFT JOIN JOB_HISTORY h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
WHERE h.EMPLOYEE_ID IS NOT NULL;
--⓺
SELECT e.LAST_NAME, e.JOB_ID FROM EMPLOYEES e
    LEFT JOIN JOB_HISTORY h ON e.EMPLOYEE_ID = h.EMPLOYEE_ID
WHERE h.EMPLOYEE_ID IS NULL;
--⓻
SELECT e.LAST_NAME, e.SALARY, e.DEPARTMENT_ID FROM EMPLOYEES e WHERE e.SALARY > (
    SELECT AVG(e1.SALARY) FROM EMPLOYEES e1 WHERE e1.DEPARTMENT_ID = e.DEPARTMENT_ID
);
--⓼
SELECT e.LAST_NAME, e.SALARY FROM EMPLOYEES e WHERE MANAGER_ID = (
    SELECT e1.EMPLOYEE_ID FROM EMPLOYEES e1 WHERE LAST_NAME = 'Kochhar'
);
--⓽
SELECT * FROM (
    SELECT e.LAST_NAME, e.SALARY FROM EMPLOYEES e ORDER BY e.SALARY DESC
) WHERE ROWNUM < 4;
--⓾
SELECT e.LAST_NAME FROM EMPLOYEES e WHERE 
    e.JOB_ID = 'FI_ACCOUNT' and e.SALARY > (
SELECT AVG(e1.SALARY) FROM EMPLOYEES e1 WHERE e1.JOB_ID = e.JOB_ID
);
