create index idx_appointments_patient_id on appointments(patient_id);
create index idx_appointments_doctor_id on appointments(doctor_id);
create index idx_appointments_date on appointments(appointment_date);
create index idx_appointments_status on appointments(status);
create index idx_prescriptions_appointment_id on prescriptions(appointment_id);
create index idx_prescriptions_medication_id on prescriptions(medication_id);


explain analyze 
select 
    a.appointment_date, 
    p.full_name,
    a.status
from appointments a
join patients p using(patient_id)
join prescriptions pr using(appointment_id)
where a.doctor_id = 42 
  and a.appointment_date >= '2026-01-01' 
  and a.status = 'completed';
