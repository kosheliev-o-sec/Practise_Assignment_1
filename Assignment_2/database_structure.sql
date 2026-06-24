--Створюємо 3 таблички
create table patients (
    patient_id serial primary key,
    full_name varchar(150) not null,
    date_of_birth date not null,
    email varchar(100) unique
);


create table doctors (
    doctor_id serial primary key,
    full_name varchar(150) not null,
    specialization varchar(50) not null,
    work_experience int
);

create table appointments (
    appointment_id serial primary key,
    patient_id int references patients(patient_id) on delete cascade,
    doctor_id int references doctors(doctor_id) on delete cascade,
    appointment_date date not null,
    status varchar(20) not null --Буде 3 статуси: 'completed', 'canceled', 'in_process'
);
