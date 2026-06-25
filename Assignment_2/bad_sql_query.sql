explain analyze 
select p.full_name, 

(select d.full_name from doctors d 
where d.doctor_id = a.doctor_id) -- Для кожного запису окремо шукаємо ім'я лікаря 
as doctor_name,

(select d.specialization from doctors d 
where d.doctor_id=a.doctor_id)  -- Для кожного запису окремо шукаємо спеціалізацію лікаря
as specialization,

a.appointment_date, a.status
from appointments a

join patients p on p.patient_id = a.patient_id -- Об'єднуємо appointments та patients, за patient_id
where a.doctor_id in 
(select doctor_id from doctors d 
where work_experience >= 5 and work_experience <=10) -- Отримуємо список лікарів зі стажем від 5 до 10 р.

and a.patient_id in 
(select patient_id from patients p 
where email is not null )  -- Отримуємо пацієнтів які мають імейл

and (select count(*) from appointments a2      --Для кожного рядка рахуємо скільки всього прийомів має пацієнт
where a2.patient_id = a.patient_id) > 1			-- Лишаємо лише тих пацієнтів хто має більше 1 прийому
--Якщо всі три умови правдиві, рядок потрапляє в результат
  
order by (select full_name from doctors d --Сортуємо за іменами лікарів
where d.doctor_id = a.doctor_id);
