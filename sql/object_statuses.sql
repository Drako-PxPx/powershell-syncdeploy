set ver off pages 999 heading off feedback off
prompt [
select json_object
  ( key 'S'  value decode(status,'VALID','V','INVALID','I'),
    key 'OT' value decode(object_type, 'SYNONYM',      'SN',
                                       'PACKAGE BODY', 'PB',
                                       'TYPE BODY',    'TB',
                                       'TRIGGER',      'TG',
                                       'PACKAGE',      'PK',
                                       'PROCEDURE',    'PC',
                                       'FUNCTION',     'FC',
                                       'TYPE',         'TP',
                                       'MATERIALIZED VIEW','MV',
                                       'VIEW', 'VW'
                         ),
    key 'ON' value object_name
  ) || ','
  from dba_objects
 where owner = '&1.'
   and object_type = '&2.'
 order by object_name;
prompt {}]
exit;