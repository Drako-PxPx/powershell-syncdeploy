set ver off pages 999 heading off feedback off
prompt [
select json_object

  ( key 'status'  value status,
    key 'object-type' value object_type,
    key 'object-name' value object_name,
    key 'owner' value owner
  ) || ','
  from all_objects  
 where object_type in ('SYNONYM','PACKAGE BODY','TYPE BODY','TRIGGER','PACKAGE','PROCEDURE','FUNCTION','TYPE','MATERIALIZED VIEW','VIEW')
 order by owner, object_name;
prompt {}]
exit;