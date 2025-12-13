-- 4
ALTER TABLE lugar 
ADD CONSTRAINT fk_ubica_lugar FOREIGN KEY (fk_lugar) references lugar(lug_codigo)
ON DELETE CASCADE;