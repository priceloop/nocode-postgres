CREATE FUNCTION median(VARIADIC float8[]) RETURNS float8
     AS 'MODULE_PATHNAME', 'nocode_median'
     LANGUAGE C STRICT;

CREATE FUNCTION average(VARIADIC float8[]) RETURNS float8
     AS 'MODULE_PATHNAME', 'nocode_average'
     LANGUAGE C STRICT;

CREATE FUNCTION ieee_div(float8, float8) RETURNS float8
     AS 'MODULE_PATHNAME', 'nocode_ieee_div'
     LANGUAGE C STRICT;
