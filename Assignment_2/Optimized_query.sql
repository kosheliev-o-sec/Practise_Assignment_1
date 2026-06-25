--optimized 

create index idx_appointments_patient on appointments(patient_id); --Створюємо індекси для оптимізації, щоб швидше знаходити необхідні рядки при join/where
create index idx_appointment_doctor on appointments(doctor_id); 
create index idx_work_experience on doctors(work_experience);

set enable_seqscan = off; --вимикаємо послідовне сканування таблиць щоб використати створені андекси
explain analyze 

with PatientCount as   --Створюємо цтєшку, 
(select patient_id
from appointments
group by patient_id  --Групуємо по пацієнту
having count(*) > 1) --Залишаємо пацієнтів у яких >1 appointment

select p.full_name, d.full_name as doctor_name, d.specialization, a.appointment_date, a.status --Основний select
from appointments a 
join patients p using(patient_id) --З'єднуємо appointments та patients по patient_id
join doctors d using(doctor_id) --З'єднуємо appointments та doctors по doctor_id
join PatientCount pc using(patient_id) --З'єднуємо appointments та нашу цтєшку по patient_id
where d.work_experience >= 5 and d.work_experience <= 10 and p.email is not null --Умова стаж роботи >=5, <=10
order by doctor_name; --Сортуємо за іменами лікарів

set enable_seqscan = on;
