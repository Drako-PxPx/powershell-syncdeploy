  PROCEDURE split_string
    ( p_string  IN   varchar2,
      po_fields IN OUT NOCOPY t_strings
    ) IS
    l_endpos pls_integer;
  BEGIN
    IF p_string IS NULL THEN
      RETURN;
    end if;
    l_endpos := instr(p_string,';');
    if l_endpos = 0 THEN
      l_endpos := length(p_string);
    end if;
    po_fields.extend();
    po_fields(po_fields.last) := trim( TRAILING ';' from `substr'(p_string,1,l_endpos));
    split_string( `substr'(p_string,l_endpos+1),po_fields);
  END split_string;
