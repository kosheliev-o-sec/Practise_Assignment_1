create user my_admin;
create user doctor;
create user receptionist;

grant all privileges on all tables in schema public to my_admin;

grant select on patients, patient_profiles, medications, departments, doctors to doctor;
grant select, insert, update on appointments, prescriptions to doctor;

grant select, insert, update on patients, patient_profiles, appointments to receptionist;
grant select on doctors, departments to receptionist;



create view patient_info as --"Безпечний" view
select 
  p.full_name as patient_name,
  p.phone as patient_phone,
  p.date_of_birth
from patients p;


create view hospital_schedule as -- View для перегляду розкладу
select 
  a.appointment_date,
  a.status,
  d.full_name as doctor_name,
  p.full_name as patient_name
from appointments a
join doctors d using(doctor_id)
join patients p using(patient_id)
where status='scheduled';

select * from hospital_schedule;


create or replace procedure update_appointment_status(   --Процедура для оновлення статусу прийому, з перевірками
    pr_appointment_id int,
    pr_new_status varchar
)
language plpgsql
as $$
begin
if pr_new_status not in ('scheduled', 'completed', 'cancelled') then   -- Перевіряємо, чи введений статус є дозволеним
raise exception 'Такого статусу не існує';
end if;
update appointments      -- Оновлення статусу в таблиці
set status = pr_new_status
where appointment_id = pr_appointment_id;  -- Перевірка на інтуп id
commit; -- Закомічуєм транзакцію
end;
$$;


create or replace function add_new_appointment(  -- Функція додавання записів
f_patient_id int,
f_doctor_id int,
f_app_date timestamp
)
returns void -- Повертаєм нічого
language plpgsql
as $$
begin
    -- Вставляємо дані, статус ставимо 'scheduled'
    insert into appointments (patient_id, doctor_id, appointment_date, status)
    values (f_patient_id, f_doctor_id, f_app_date, 'scheduled');
end;
$$;

