"""
Generate a messy, realistic employee dataset (10 columns, 10,000 rows).
Run: python3 generate_dataset.py
Output: employees_raw.csv (UTF-8)
The seed is fixed, so the output is reproducible.
"""
import csv
import random
from datetime import date, timedelta

random.seed(42)

TOTAL_ROWS = 10_000
N_DUPLICATES = 300
N_BASE = TOTAL_ROWS - N_DUPLICATES

FIRST = ["James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda",
         "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
         "Thomas", "Sarah", "Charles", "Karen", "Daniel", "Nancy", "Matthew", "Lisa",
         "Anthony", "Betty", "Mark", "Sandra", "Paul", "Ashley", "Steven", "Emily",
         "Andrew", "Donna", "Kevin", "Michelle", "Brian", "Carol", "Jose", "Amanda",
         "Omar", "Fatima", "Wei", "Priya", "Raj", "Aisha", "Hiro", "Mei", "Zoe", "Rene"]
LAST = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
        "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
        "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
        "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
        "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
        "Khan", "Rahman", "Chen", "Patel", "Singh", "Ali", "Tanaka", "Kim", "Murphy", "Ahmed"]

DEPTS = {
    "Human Resources": (["Human Resources", "HR", "hr", "H.R.", "human resources", "Human Resource", "Hr "],
                        ["HR Manager", "HR Assistant", "Recruiter", "Senior Recruiter", "Payroll Specialist"],
                        (40000, 95000)),
    "Finance": (["Finance", "finance", "FINANCE", "Fin.", "Finance Dept", "Accounting & Finance"],
                ["Accountant", "Senior Accountant", "Financial Analyst", "Finance Manager", "Auditor"],
                (50000, 130000)),
    "IT": (["IT", "I.T.", "it", "Information Technology", "Info Tech", "IT Dept"],
           ["Software Engineer", "Senior Software Engineer", "Data Analyst", "DevOps Engineer",
            "IT Support Specialist", "IT Manager"],
           (60000, 170000)),
    "Sales": (["Sales", "sales", "SALES", "Sales Dept", "Sales & BD"],
              ["Sales Representative", "Account Executive", "Sales Manager", "Senior Account Executive",
               "Sales Assistant"],
              (35000, 140000)),
    "Marketing": (["Marketing", "marketing", "MKTG", "Mktg", "Marketing Dept", "MARKETING"],
                  ["Marketing Specialist", "Marketing Manager", "Content Writer", "SEO Analyst",
                   "Senior Marketing Specialist"],
                  (42000, 120000)),
    "Operations": (["Operations", "operations", "Ops", "OPS", "Operations Dept", "Oprations"],
                   ["Operations Manager", "Operations Assistant", "Logistics Coordinator",
                    "Supply Chain Analyst", "Warehouse Supervisor"],
                   (38000, 110000)),
}
DEPT_WEIGHTS = [10, 14, 24, 22, 14, 16]

STATUS = {
    "Active": ["Active", "active", "ACTIVE", "Actv", "A"],
    "Terminated": ["Terminated", "terminated", "Term", "T"],
    "Resigned": ["Resigned", "resigned", "Resign"],
    "On Leave": ["On Leave", "on leave", "On-Leave", "LOA", "Leave"],
}
STATUS_WEIGHTS = [68, 12, 14, 6]

LOCATIONS = {
    "New York": ["New York", "NYC", "New York City", "new york", "NY", "N.Y.C", "New Yrok"],
    "Chicago": ["Chicago", "chicago", "CHI", "Chicago, IL", "Chcago"],
    "Austin": ["Austin", "austin", "Austin, TX", "ATX", "AUSTIN"],
    "Seattle": ["Seattle", "SEATTLE", "Seattle, WA", "Sea", "Seatle"],
    "San Francisco": ["San Francisco", "SF", "San Fran", "san francisco", "San Francisco, CA"],
    "Remote": ["Remote", "remote", "WFH", "Work From Home", "Remote "],
}
LOC_WEIGHTS = [22, 18, 14, 14, 18, 14]

NULL_TOKENS = ["", "NULL", "null", "N/A", "n/a", "-", "None", "unknown"]
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def null_token():
    return random.choice(NULL_TOKENS)


def junk_ws(s):
    """Randomly add leading/trailing/double spaces."""
    if not s:
        return s
    r = random.random()
    if r < 0.04:
        return " " + s
    if r < 0.09:
        return s + " "
    if r < 0.11:
        return s.replace(" ", "  ")
    return s


def make_id(i):
    r = random.random()
    if r < 0.03:
        return null_token()
    if r < 0.80:
        return f"EMP-{i:05d}"
    if r < 0.88:
        return f"emp{i}"
    if r < 0.93:
        return str(i)
    if r < 0.97:
        return f"E{i:05d}"
    return f"EMP_{i:05d}"


def make_name(first, last):
    r = random.random()
    if r < 0.60:
        s = f"{first} {last}"
    elif r < 0.68:
        s = f"{first} {last}".upper()
    elif r < 0.76:
        s = f"{first} {last}".lower()
    elif r < 0.82:
        s = f"{last}, {first}"
    elif r < 0.88:
        s = f"{first}   {last}"
    elif r < 0.92:
        s = f"{random.choice(['Mr.', 'Ms.', 'Mrs.', 'Dr.'])} {first} {last}"
    elif r < 0.94:
        s = first
    elif r < 0.97:
        return null_token()
    else:
        s = f"{first} {last} "
    return junk_ws(s)


def make_email(first, last):
    f = first.lower().replace(" ", "")
    l = last.lower().replace(" ", "")
    base = f"{f}.{l}@northwind.com"
    r = random.random()
    if r < 0.55:
        return base
    if r < 0.65:
        return base.upper()
    if r < 0.70:
        return base.replace("@", "")
    if r < 0.76:
        return f"{f}.{l}@{random.choice(['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com'])}"
    if r < 0.80:
        return base + " "
    if r < 0.84:
        return f"{f}.{l}@northwind"
    if r < 0.86:
        return f"{f}..{l}@northwind.com"
    if r < 0.88:
        return f"{f}.{l}@@northwind.com"
    if r < 0.90:
        return f"{f} {l}@northwind.com"
    if r < 0.94:
        return null_token()
    return base.title()


def make_phone():
    a, b, c = random.randint(201, 989), random.randint(200, 999), random.randint(0, 9999)
    r = random.random()
    if r < 0.25:
        return f"({a}) {b}-{c:04d}"
    if r < 0.45:
        return f"{a}-{b}-{c:04d}"
    if r < 0.58:
        return f"{a}{b}{c:04d}"
    if r < 0.70:
        return f"+1 {a} {b} {c:04d}"
    if r < 0.78:
        return f"{a}.{b}.{c:04d}"
    if r < 0.84:
        return f"1-{a}-{b}-{c:04d}"
    if r < 0.88:
        return f"{a}-{b}"            # too short
    if r < 0.91:
        return f"{a}-{b}-{c:04d} ext. {random.randint(10, 999)}"
    if r < 0.93:
        return "abc-defg"
    return null_token()


def make_dept(canon):
    variants = DEPTS[canon][0]
    r = random.random()
    if r < 0.03:
        return null_token()
    return junk_ws(random.choice(variants))


def make_title(canon):
    t = random.choice(DEPTS[canon][1])
    r = random.random()
    if r < 0.03:
        return null_token()
    if r < 0.55:
        s = t
    elif r < 0.65:
        s = t.lower()
    elif r < 0.72:
        s = t.upper()
    elif r < 0.88:
        s = t.replace("Senior", "Sr.").replace("Manager", "Mgr").replace("Assistant", "Asst.")
    else:
        s = t + " "
    return s


def make_hire_date(d):
    r = random.random()
    if r < 0.04:
        return null_token()
    if r < 0.07:
        return random.choice(["31/02/2021", "2099-01-01", "1900-01-01", "0000-00-00",
                              "13/13/2020", "2026-15-40", "2030-06-15"])
    if r < 0.47:
        return d.strftime("%Y-%m-%d")                      # ISO
    if r < 0.67:
        return d.strftime("%d/%m/%Y")                      # DD/MM/YYYY (slashes)
    if r < 0.82:
        return d.strftime("%m-%d-%Y")                      # MM-DD-YYYY (dashes)
    if r < 0.92:
        return f"{d.day} {MONTHS[d.month - 1]} {d.year}"   # 5 Jan 2020
    if r < 0.97:
        return f"{MONTHS[d.month - 1]} {d.day}, {d.year}"  # Jan 5, 2020
    return d.strftime("%Y/%m/%d")


def make_salary(lo, hi):
    s = round(random.randint(lo, hi), -2)
    r = random.random()
    if r < 0.05:
        return null_token()
    if r < 0.40:
        return str(s)
    if r < 0.58:
        return f"${s:,}"
    if r < 0.68:
        return f"{s:,.2f}"
    if r < 0.76:
        return f"{s // 1000}k"
    if r < 0.82:
        return f"{s} USD"
    if r < 0.86:
        return f"${s:,}.00"
    if r < 0.88:
        return str(-s)
    if r < 0.90:
        return "0"
    if r < 0.92:
        return random.choice(["9999999", "1250000", "999999"])
    if r < 0.94:
        return f"{round(s / 2080, 2)}/hr"
    if r < 0.96:
        return "TBD"
    return str(s)


def make_status():
    canon = random.choices(list(STATUS), weights=STATUS_WEIGHTS)[0]
    if random.random() < 0.04:
        return null_token()
    return junk_ws(random.choice(STATUS[canon]))


def make_location():
    canon = random.choices(list(LOCATIONS), weights=LOC_WEIGHTS)[0]
    if random.random() < 0.05:
        return null_token()
    return junk_ws(random.choice(LOCATIONS[canon]))


HEADER = ["employee_id", "full_name", "email", "phone", "department",
          "job_title", "hire_date", "salary", "employment_status", "work_location"]

start, end = date(2005, 1, 1), date(2026, 9, 30)
span = (end - start).days

rows = []
for i in range(1, N_BASE + 1):
    emp_no = 1000 + i
    first, last = random.choice(FIRST), random.choice(LAST)
    canon = random.choices(list(DEPTS), weights=DEPT_WEIGHTS)[0]
    d = start + timedelta(days=random.randint(0, span))
    rows.append([
        make_id(emp_no),
        make_name(first, last),
        make_email(first, last),
        make_phone(),
        make_dept(canon),
        make_title(canon),
        make_hire_date(d),
        make_salary(*DEPTS[canon][2]),
        make_status(),
        make_location(),
    ])

# Duplicates: half exact copies, half near-duplicates (case / spacing / format drift)
for src in random.sample(rows, N_DUPLICATES):
    dup = list(src)
    if random.random() < 0.5:
        if dup[0] and dup[0].upper().startswith("EMP"):
            dup[0] = dup[0].lower()
        dup[1] = dup[1].upper() if random.random() < 0.5 else dup[1].lower()
        dup[2] = dup[2].upper()
        if random.random() < 0.5:
            dup[7] = dup[7] + " "
    rows.append(dup)

random.shuffle(rows)

with open("employees_raw.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(HEADER)
    w.writerows(rows)

print(f"Wrote {len(rows)} rows to employees_raw.csv")
