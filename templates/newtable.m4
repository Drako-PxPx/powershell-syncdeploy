declare
  l_exists number;
begin
  select count(0)
    into l_exists
    from all_objects
   where object_name = '__TABLE_NAME__'
     and owner = '__TABLE_OWNER__';

  if l_exists = 0 then
    execute immediate q'[
include(__TABLEDEF__)
      ]';

    execute immediate q'[
comment on column "__TABLE_OWNER__"."__TABLE_NAME__"."__PK__" is
    'Primary Key. Sequence=__KEYSEQUENCE__'
      ]';

  else
    dbms_output.put_line('__TABLE_NAME__ table already exists');
  end if;
end;
/
