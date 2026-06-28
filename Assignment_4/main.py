import psycopg2
from psycopg2.extras import execute_values
from faker import Faker
import random
from datetime import datetime, timedelta

DB_CONFIG = {
    "host": 'localhost',    # put your credentials here
    "port": "5432", # put your credentials here
    "dbname": "",   # put your credentials here
    "user": "postgres", # put your credentials here
    "password": "", # put your credentials here
}

fake = Faker()


NUM_PATIENTS = 100000
NUM_DEPARTMENTS = 15
NUM_DOCTORS = 500
NUM_MEDICATIONS = 1000
NUM_APPOINTMENTS = 300000
NUM_PRESCRIPTIONS = 500000

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

def generate_patients(cursor):
    print(f"генеруємо {NUM_PATIENTS} пацієнтів та їхні профілі...")
    patients_data = []
    profiles_data = []
    blood_types = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
    
    for i in range(1, NUM_PATIENTS + 1):
        patients_data.append((
            fake.name(),
            fake.date_of_birth(minimum_age=1, maximum_age=90),
            fake.unique.email(),
            fake.phone_number()[:20]
        ))
        profiles_data.append((
            i, # patient_id збігається, бо зв'язок 1:1
            fake.address()[:250].replace('\n', ' '),
            random.choice(blood_types),
            fake.phone_number()[:150]
        ))

     
        if i % 10000 == 0:
            execute_values(cursor, "insert into patients (full_name, date_of_birth, email, phone) values %s", patients_data)
            execute_values(cursor, "insert into patient_profiles (patient_id, address, blood_type, emergency_contact) values %s", profiles_data)
            patients_data.clear()
            profiles_data.clear()
            print(f"  вставлено {i} пацієнтів...")

def generate_departments_and_doctors(cursor):
    print("генеруємо відділення та лікарів...")
    deps = [(f"Department {fake.unique.word().capitalize()}", random.randint(1, 10)) for _ in range(NUM_DEPARTMENTS)]
    execute_values(cursor, "insert into departments (department_name, floor) values %s", deps)

    docs = []
    for _ in range(NUM_DOCTORS):
        docs.append((
            random.randint(1, NUM_DEPARTMENTS),
            f"Dr. {fake.name()}",
            fake.job()[:80],
            random.randint(0, 40),
            fake.unique.email()
        ))
    execute_values(cursor, "insert into doctors (department_id, full_name, specialization, work_experience, email) values %s", docs)

def generate_medications(cursor):
    print("генеруємо ліки...")
    meds = []
    for _ in range(NUM_MEDICATIONS):
        meds.append((
            fake.word().capitalize() + " " + fake.word(),
            fake.company(),
            round(random.uniform(5.0, 500.0), 2)
        ))
    execute_values(cursor, "insert into medications (medication_name, manufacturer, price) values %s", meds)

def generate_appointments(cursor):
    print(f"генеруємо {NUM_APPOINTMENTS} візитів...")
    statuses = ['scheduled', 'completed', 'cancelled']
    appts = []
    start_date = datetime.now() - timedelta(days=365)
    
    for i in range(1, NUM_APPOINTMENTS + 1):
        appts.append((
            random.randint(1, NUM_PATIENTS),
            random.randint(1, NUM_DOCTORS),
            start_date + timedelta(days=random.randint(0, 365), hours=random.randint(8, 18)),
            random.choice(statuses)
        ))
        
        if i % 10000 == 0:
            execute_values(cursor, "insert into appointments (patient_id, doctor_id, appointment_date, status) values %s", appts)
            appts.clear()
            print(f"  вставлено {i} візитів...")

def generate_prescriptions(cursor):
    print(f"генеруємо {NUM_PRESCRIPTIONS} рецептів...")
    presc = []
    for i in range(1, NUM_PRESCRIPTIONS + 1):
        presc.append((
            random.randint(1, NUM_APPOINTMENTS),
            random.randint(1, NUM_MEDICATIONS),
            f"{random.randint(1,3)} pills {random.choice(['daily', 'weekly'])}",
            random.randint(3, 30)
        ))
        
        if i % 10000 == 0:
            execute_values(cursor, "insert into prescriptions (appointment_id, medication_id, dosage, duration_days) values %s", presc)
            presc.clear()
            print(f"  вставлено {i} рецептів...")

def main():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            
            generate_patients(cursor)
            generate_departments_and_doctors(cursor)
            generate_medications(cursor)
            generate_appointments(cursor)
            generate_prescriptions(cursor)
            
            conn.commit()
            print("успіх! базу заповнено.")
    except Exception as e:
        conn.rollback()
        print(f"помилка: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    main()
