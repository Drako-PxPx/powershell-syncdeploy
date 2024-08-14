select listagg(distinct owner,';')
  from all_objects
 where object_type in ('SYNONYM','PACKAGE BODY','TYPE BODY','TRIGGER','PACKAGE','PROCEDURE','FUNCTION','TYPE','MATERIALIZED VIEW','VIEW');
exit;