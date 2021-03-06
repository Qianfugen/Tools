--存储过程          
            --返回字段类型数据
--创建一个query_sal_by_name
create or replace procedure query_sal_by_name(
       in_name in emp.ename%type,
       out_sal out emp.sal%type
)
is
       --或者as
       --该部分用来定义存储过程中需要用到的变量
begin
       select sal into out_sal from emp where ename=in_name;
end query_sal_by_name;

--调用query_sal_by_name
declare 
    out_sal emp.sal%type := 1111;
begin
    query_sal_by_name('KING',out_sal);
    dbms_output.put_line(out_sal);
end;

            --返回行类型数据
--创建一个query_all_by_name
create or replace procedure query_all_by_name(
       in_name in emp.ename%type,
       row_emp out emp%rowtype
)
is

begin
   select * into row_emp from emp where ename=in_name;    
end;


--调用query_all_by_name
declare 
   row_emp emp%rowtype;
begin
   query_all_by_name('KING',row_emp);
   dbms_output.put_line('员工编号'||row_emp.empno||',员工姓名：'||row_emp.ename||',员工薪资：'||row_emp.sal);
end;

           --使用游标
--根据用户名模糊查询所有员工信息
--创建query_all_by_like
create or replace procedure query_all_by_like(
       in_name in emp.ename%type,
       cur_emp out sys_refcursor
)
is

begin
       open cur_emp for select * from emp where ename like '%'||in_name||'%'; 
end;

--调用query_all_by_like
declare
       cur_emp sys_refcursor;
       row_emp emp%rowtype;
begin
       query_all_by_like('S',cur_emp);
       loop
               fetch cur_emp into row_emp;
               exit when cur_emp%notfound;
               dbms_output.put_line('员工编号'||row_emp.empno||',员工姓名：'||row_emp.ename||',员工薪资：'||row_emp.sal);
       end loop;
       close cur_emp;
end;


--方法
--根据员工编号,返回工资加奖金 add_sal_comm
create or replace function add_sal_comm(
       v_empno emp.empno%type
)return emp.sal%type
is
       v_sal_and_comm emp.sal%type;
begin
       select (sal+nvl(comm,0)) into v_sal_and_comm from emp where empno=v_empno;
       return v_sal_and_comm;
end;

--可以在过程中调用
declare 
       v_sal_and_comm  emp.sal%type;  
begin
       v_sal_and_comm := add_sal_comm(7782);
       dbms_output.put_line(v_sal_and_comm);
end;     

--也可以直接在sql语句中调用
select add_sal_comm(empno) from emp;



--多条件分页查询
create or replace procedure query_all_emp_fy(
       --用于按照姓名模糊查询
       v_ename in emp.ename%type,
       --用于按照入职日期查询的开始入职日期
       v_start_hiredate in varchar2,
       --用于按照入职日期查询的结束入职日期
       v_end_hiredate in varchar2,
       --本页从第几条开始
       v_start_row in number,
       --本页到第几条结束 S '%'||'S'||'%'
       v_end_row in number,
       --返回符合要求的记录总数
       v_row_count out number,
       --返回本页数据
       v_emp_cur out sys_refcursor
)
is
       --用来拼接查询该页数据的sql语句
       v_select_emp varchar2(2000);
       --用来拼接查询符合要求记录总数的sql语句
       v_select_emp_count varchar2(2000);
       --应为上面的两条sql语句where条件一样,所以定义为一个变量
       v_select_where varchar2(2000);
begin
       --拼接查询条件
       v_select_where := ' where 1=1';
       if v_ename is not null then
          v_select_where := v_select_where||' and ename like concat(''%'',concat('''||v_ename||''',''%''))';
       end if;
       if v_start_hiredate is not null then
          v_select_where := v_select_where||' and hiredate>=to_date('''||v_start_hiredate||''',''yyyy-mm-dd'')';
       end if;
        if v_end_hiredate is not null then
          v_select_where := v_select_where||' and hiredate<=to_date('''||v_end_hiredate||''',''yyyy-mm-dd'')';
       end if;
       --拼接查询该页数据的sql语句
       v_select_emp := 'select e2.empno,e2.ename,e2.job,e2.mgr,e2.hiredate,e2.sal,e2.comm,e2.deptno from(
                       select e.*,rownum r from emp e '||v_select_where||') e2 where r between '||v_start_row||' and '||v_end_row;
       --执行该条sql语句包结果给游标
       open v_emp_cur for v_select_emp;
       --拼接查询符合要求记录总数的sql语句
       v_select_emp_count := 'select count(1) from emp '||v_select_where;
       --执行sql语句
       execute immediate v_select_emp_count into v_row_count;  
end;

declare
       --返回符合要求的记录总数
       v_row_count number;
       --系统游标
       v_emp_cur sys_refcursor;
       --游标变量
       emp_row emp%rowtype;
begin
      query_all_emp_fy('S',null,null,3,6,v_row_count,v_emp_cur);
      dbms_output.put_line('符合要求的总条数：'||v_row_count); 
      loop
          fetch v_emp_cur into emp_row;
          exit when v_emp_cur%notfound;
              dbms_output.put_line('用户编号：'||emp_row.empno||',用户名:'||emp_row.ename||',入职日期:'||emp_row.hiredate);  
      end loop;
end;






-------------------------------------------------------------------------------------------------------------------
declare
v_start_hiredate varchar2(20):='hello,world';
v_select_where varchar2(20) := 'where 1=1';
v_start_row number(5) := 3;
v_end_row number(5) := 6;
begin
dbms_output.put_line(v_select_where||' and hiredate>=to_date(''||v_start_hiredate||'',''yyyy-mm-dd'')');
                       
                       
end;


select e2.* from(
select e.*,rownum r from emp e where 1=1) e2 where r between 3 and 6

select e2.empno,e2.ename,e2.job,e2.mgr,e2.hiredate,e2.sal,e2.comm,e2.deptno from(
                       select e.*,rownum r from emp e where 1=1) e2 where r between 3 and 6
