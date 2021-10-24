import random
import string
import itertools
import datetime

random.seed(42)

FILES = [
    "Departments.sql",
    "MeetingRooms.sql",
    "Employees.sql",
    "Booker.sql",
    "Manager.sql",
    "Updates.sql",
    "HealthDeclaration.sql",
    "Joins.sql",
    "Sessions.sql"
]


# Departments
NUM_DEPARTMENT = 5
did = list(range(1, NUM_DEPARTMENT + 1))  # 5 departments
dname = [
    'Business Development',
    'Product Management',
    'Business Development',
    'Marketing',
    'Research and Development'
]

with open('Departments.sql', 'w') as f:
    for i in list(zip(did, dname)):
        sql = f"INSERT INTO Departments VALUES ({i[0]}, '{i[1]}');\n"
        f.write(sql) 


# MeetingRooms
NUM_ROOM_PER_FLOOR = 5
NUM_FLOOR = 6
NUM_ROOM = NUM_ROOM_PER_FLOOR * NUM_FLOOR
LEN_RNAME = 8
room = list(range(1, NUM_ROOM_PER_FLOOR + 1)) * NUM_FLOOR # 5 rooms per floor
floor = list(itertools.chain.from_iterable([[i] * NUM_ROOM_PER_FLOOR for i in range(1, NUM_FLOOR + 1)]))  # 6 floors
did = [random.choice(did) for _ in range(NUM_ROOM)]  # randomly assign department for each room
rname = [''.join(random.choices(string.ascii_uppercase + string.ascii_lowercase, k=LEN_RNAME)) for _ in range(NUM_ROOM)]

with open('MeetingRooms.sql', 'w') as f:
    for i in list(zip(room, floor, did, rname)):
        sql = f"INSERT INTO MeetingRooms VALUES ({i[0]}, {i[1]}, {i[2]}, '{i[3]}');\n"
        f.write(sql) 

# Employees
NUM_EMPLOYEE = 50
LEN_ENAME = 6
LEN_EMAIL = 10
LEN_PHONE_NUM = 8
START_DATE = datetime.date(2020, 9, 1)
END_DATE = datetime.date(2021, 9, 30)
PERCENTAGE_RESIGNED = 0.1

def generate_date(start_date, end_date):
    time_between_dates = end_date - start_date
    days_between_dates = time_between_dates.days
    random_number_of_days = random.randrange(days_between_dates)
    random_date = start_date + datetime.timedelta(days=random_number_of_days)
    return str(random_date)


eid = list(range(1, NUM_EMPLOYEE + 1))
ename = [random.choice(string.ascii_uppercase) + ''.join(random.choices(string.ascii_lowercase, k=LEN_RNAME - 1)) for _ in range(NUM_EMPLOYEE)]
email = [n.lower() + '@gmail.com' for n in ename]
home_number = [''.join(random.choices(string.digits, k=LEN_PHONE_NUM)) for _ in range(NUM_EMPLOYEE)]
mobile_number = [''.join(random.choices(string.digits, k=LEN_PHONE_NUM)) for _ in range(NUM_EMPLOYEE)]
office_number = [''.join(random.choices(string.digits, k=LEN_PHONE_NUM)) for _ in range(NUM_EMPLOYEE)]
resigneddate = [generate_date(START_DATE, END_DATE) if random.random() < PERCENTAGE_RESIGNED else 'NULL' for _ in range(NUM_EMPLOYEE)]
did = [random.choice(did) for _ in range(NUM_EMPLOYEE)] 

with open('Employees.sql', 'w') as f:
    for i in list(zip(eid, ename, email, home_number, mobile_number, office_number, resigneddate, did)):
        if i[6] == 'NULL':
            sql = f"INSERT INTO Employees VALUES ({i[0]}, '{i[1]}', '{i[2]}', {i[3]}, {i[4]}, {i[5]}, {i[6]}, {i[7]});\n"
        else:
            sql = f"INSERT INTO Employees VALUES ({i[0]}, '{i[1]}', '{i[2]}', {i[3]}, {i[4]}, {i[5]}, '{i[6]}', {i[7]});\n"
        f.write(sql) 

# Booker
NUM_BOOKER = 20
eid_booker = sorted(random.sample(eid, k=NUM_BOOKER))
with open('Booker.sql', 'w') as f:
    for i in eid_booker:
        sql = f"INSERT INTO Booker VALUES ({i});\n"
        f.write(sql) 

# Manager
NUM_MANAGER = 10
eid_manager = sorted(random.sample(eid_booker, k=NUM_MANAGER))
with open('Manager.sql', 'w') as f:
    for i in eid_manager:
        sql = f"INSERT INTO Manager VALUES ({i});\n"
        f.write(sql) 

# HealthDeclaration
DATES = list(str(START_DATE + datetime.timedelta(days=i)) for i in range((END_DATE - START_DATE).days + 1))
PERCENTAGE_FORGET = 0.03
PERCENTAGE_FEVER_LO = 0.02
PERCENTAGE_FEVER_HI = 0.7
with open('HealthDeclaration.sql', 'w') as f:
    for e in eid:
        percentage_fever = PERCENTAGE_FEVER_LO
        for d in DATES:
            if random.random() < PERCENTAGE_FORGET:
                # simulate forget to declare
                continue

            if random.random() < percentage_fever:
                # simulate fever
                percentage_fever = PERCENTAGE_FEVER_HI
                t = round(random.randint(376, 429) / 10, 1)  # random num, 37.5 < x < 43.0
                sql = f"INSERT INTO HealthDeclaration VALUES ({e}, '{d}', {t}, TRUE);\n"
                f.write(sql) 
            else:
                # simulate non-fever
                percentage_fever = PERCENTAGE_FEVER_LO
                t = round(random.randint(341, 375) / 10, 1)  # random num, 34.0 < x <= 37.5
                sql = f"INSERT INTO HealthDeclaration VALUES ({e}, '{d}', {t}, FALSE);\n"
                f.write(sql) 

# Sessions
# select mr.floor, mr.room, m.eid from manager m, employees e, meetingrooms mr where m.eid = e.eid and e.did = mr.did order by mr.floor, mr.room;
q_floor = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]
q_room =  [1, 1, 2, 2, 3, 3, 2, 2, 3, 3, 4, 4, 5, 5, 1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 2, 2, 3, 3, 4, 4, 5, 5, 2, 2, 3, 3, 3, 3, 5, 5, 5, 5, 1, 1, 2, 2, 3, 3, 5, 5, 5, 5]
q_eid_manager = [44, 34, 34, 44, 29, 48, 34, 44, 2, 17, 44, 34, 2, 17, 1, 3, 5, 14, 44, 34, 34, 44, 34, 44, 2, 17, 2, 17, 44, 34, 17, 2, 2, 17, 14, 3, 1, 5, 14, 1, 3, 5, 2, 17, 48, 29, 44, 34, 5, 3, 14, 1]

# Joins


# Updates
