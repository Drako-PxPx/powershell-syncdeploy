declare
  c_schema_name constant varchar2(30)       := '__TABLE_OWNER__';
  c_table_name  constant varchar2(30)       := '__TABLE_NAME__';
  c_index_tablespace constant varchar2(30)  := '__IX_TBS__';
  c_indexnames constant varchar2(4000)      := '__INDEX_LIST__';
  c_indexcolumns constant varchar2(4000)    := '__INDEX_COLUMNS__';
  
  l_sqlcmd varchar2(4000);
  
include(`t_strings.sql')
  
  l_indexnames    t_strings;
  l_indexcolumns  t_strings;

include(`split_string.sql')

  function exist_index (p_index_name in varchar2)
    return boolean as
    l_exists number;
  begin
    select count(0)
      into l_exists
      from all_indexes
     where index_name = p_index_name
      and TABLE_OWNER = c_schema_name;
    return l_exists > 0;
  end exist_index;
begin
  
  l_indexnames    := NEW t_strings();
  l_indexcolumns  := NEW t_strings();
  
  split_string(c_indexnames, l_indexnames);
  split_string(c_indexcolumns,l_indexcolumns);
  
  FOR i IN l_indexnames.FIRST .. l_indexnames.LAST LOOP
    if not exist_index(l_indexnames(i)) then
      l_sqlcmd := 'create index ' || c_schema_name || '.' || l_indexnames(i) || ' on ' || c_schema_name || '.' || c_table_name || '(' || l_indexcolumns(i) || ') tablespace ' || c_index_tablespace;
      dbms_output.put_line(l_sqlcmd);
    else
      dbms_output.put_line('Index ' || l_indexnames(i) || ' already exists');
    end if;
  end loop;
  
end;
/
