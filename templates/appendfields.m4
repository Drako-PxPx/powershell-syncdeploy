DECLARE
  c_field_names  constant varchar2(4000)  := '__FIELDS_LIST__';
  c_data_types   constant varchar2(4000)  := '__DATA_TYPES__';
  c_table_name   constant varchar2(30)    := '__TABLE_NAME__';
  c_schema_name  constant varchar2(30)    := '__TABLE_OWNER__';

include(`t_strings.sql')
  
  l_fields     t_strings;
  l_datatypes  t_strings;
  l_sqlcmd     varchar2(200);
  
include(`split_string.sql')
  
  FUNCTION field_exists
    ( p_schema_name IN varchar2,
      p_table_name  IN varchar2,
      p_field_name  IN varchar2
    ) RETURN boolean
  AS
    l_count pls_integer;
  BEGIN
    select count(0)
      into l_count
      from all_tab_columns
     where owner        = p_schema_name
       and table_name   = p_table_name
       and column_name  = p_field_name;
    
    return l_count > 0;
  end field_exists;

BEGIN
  l_fields    := NEW t_strings();
  l_datatypes := NEW t_strings();
  
  split_string(c_field_names,l_fields);
  split_string(c_data_types,l_datatypes);
  
  FOR i IN l_fields.FIRST .. l_fields.LAST LOOP
    if not field_exists(c_schema_name, c_table_name, l_fields(i)) then
      l_sqlcmd := 'alter table ' || c_schema_name || '.' || c_table_name || ' add ' || l_fields(i) || ' ' || l_datatypes(i);
      execute immediate l_sqlcmd;
    else
      dbms_output.put_line('Field ' || l_fields(i) || ' Aleady exists on __TABLE_NAME__');
    end if;
    
  end loop;
END;
/