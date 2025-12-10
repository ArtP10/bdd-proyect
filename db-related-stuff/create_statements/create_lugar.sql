-- 3
create table lugar (
    lug_codigo serial primary key,
    lug_tipo varchar(50) not null,
    lug_nombre varchar(100) not null,
    fk_lugar integer,
    CONSTRAINT check_lug_tipo CHECK (lug_tipo IN ('Pais', 'Estado', 'Ciudad', 'Municipio', 'Parroquia'))
)