drop table if exists prescriptions cascade;
drop table if exists medications cascade;
drop table if exists appointments cascade;
drop table if exists patient_profiles cascade;
drop table if exists doctors cascade;
drop table if exists departments cascade;
drop table if exists patients cascade;


-- Пацієнти

create table patients(
    patient_id serial primary key,  -- Унікальний id
    full_name varchar(150) not null,
    date_of_birth date not null,
    email varchar(120) unique,
    phone varchar(20)
);

-- Профіль пацієнтів

create table patient_profiles( 
    patient_id int primary key, 
    address varchar(250),
    blood_type varchar(5),
    emergency_contact varchar(150),

    constraint fk_profile_patient  -- Зовнішній ключ на табличку patients
        foreign key(patient_id)
        references patients(patient_id)
        on delete cascade		-- При видаленні пацієнта профіль також видаляється
);

-- Департаменти

create table departments(
    department_id serial primary key,   -- Унікальний id
    department_name varchar(100) unique not null,
    floor int check(floor>0)    -- Поверх обов'язково більше 0, або видасть помилку
);

-- Лікарі

create table doctors(
    doctor_id serial primary key,
    department_id int not null,
    full_name varchar(150) not null,
    specialization varchar(80) not null,
    work_experience int
        check(work_experience>=0),  -- Стаж повинен бути додатнім
    email varchar(120) unique,  -- Унікальний email 
    
    constraint fk_department       -- Зовнішній ключ на табличку departments
        foreign key(department_id)
        references departments(department_id)
        -- Немає on delete cascade щоб не дозволяло видалити department, якщо є doctors
);

-- Записи

create table appointments(
    appointment_id serial primary key,
    patient_id int not null,
    doctor_id int not null,
    appointment_date timestamp not null,
    status varchar(20)
        check(status in
        ('scheduled','completed','cancelled')), -- Усі дозволені статуси прийому

    constraint fk_patient			-- Зовнішній ключ на табличку patients
    	foreign key(patient_id)
    	references patients(patient_id)
    	on delete cascade,  -- Записи видаляються якщо видалити пацієнта

    constraint fk_doctor		-- Зовнішній ключ на табличку doctors
        foreign key(doctor_id)
        references doctors(doctor_id)
        on delete cascade  -- Записи видаляються якщо видалити доктора
);

-- Ліки

create table medications(
    medication_id serial primary key,
    medication_name varchar(150) not null,
    manufacturer varchar(150),
    price numeric(10,2)
        check(price>=0)   -- Ціна може бути лише додатньою
);

-- Рецепти

create table prescriptions(
    prescription_id serial primary key,
    appointment_id int not null,
    medication_id int not null,
    dosage varchar(100),
    duration_days int
        check(duration_days>0),  -- Тривалість лікування лише додатня

    constraint fk_appointment    -- Зовнішній ключ на табличку appointments
        foreign key(appointment_id)
        references appointments(appointment_id)
        on delete cascade,  -- Рецепти видаляються якщо видалити прийом

    constraint fk_medication     -- Зовнішній ключ на табличку medications
        foreign key(medication_id)
        references medications(medication_id)
        on delete cascade  -- Рецепти ліків видаляються якщо видалити ці ліки
);






