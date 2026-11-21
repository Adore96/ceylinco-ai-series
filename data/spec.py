"""Single source of truth for the Week 2 and Week 3 synthetic data.

Seed SQL (sql/week2/01_seed_data.sql), the garage-estimate images and their
truth JSON (data/estimates/) are all generated from this file, so they can
never disagree. The call transcripts (data/calls/) were written first; every
ID they mention is created here. check_spec() proves that.

Fictional insurer: Lanka Shield Assurance. Every name, NIC, phone number,
registration number and amount is invented.
"""
import json
import pathlib
import re

HERE = pathlib.Path(__file__).parent

# ---------------------------------------------------------------------------
# Customers. The first block are people who appear in the call transcripts.
# (key, full_name, nic, city, branch)
# ---------------------------------------------------------------------------
NAMED = [
    ("sunil",     "Sunil Jayawardena",       "671234567V",   "Nugegoda",     "Colombo"),
    ("chamari",   "Chamari Fernando",        "745501234V",   "Moratuwa",     "Colombo"),
    ("kasun",     "Kasun Ranasinghe",        "198812304567", "Maharagama",   "Colombo"),
    ("tharushi",  "Tharushi Wickramasinghe", "199561203345", "Kandy",        "Kandy"),
    ("priyantha", "Priyantha Silva",         "199012345678", "Panadura",     "Colombo"),
    ("dilrukshi", "Dilrukshi Perera",        "827702345V",   "Kotte",        "Colombo"),
    ("nuwan",     "Nuwan Bandara",           "198603401122", "Galle",        "Galle"),
    ("lalith",    "Lalith Gunasekara",       "651122334V",   "Kurunegala",   "Kurunegala"),
    ("ajith",     "Ajith Kumara",            "780934567V",   "Kadawatha",    "Colombo"),
    ("sarath",    "Sarath Herath",           "620455678V",   "Matale",       "Kandy"),
    ("sanduni",   "Sanduni Rathnayake",      "199270506789", "Peradeniya",   "Kandy"),
    ("rohan",     "Rohan de Silva",          "700812345V",   "Dehiwala",     "Colombo"),
    ("anoma",     "Anoma Jayasinghe",        "766123456V",   "Gampaha",      "Gampaha"),
    ("chathura",  "Chathura Senanayake",     "199104502233", "Kelaniya",     "Gampaha"),
    ("dhammika",  "Dhammika Pathirana",      "720345678V",   "Matara",       "Matara"),
    ("rasika",    "Rasika Mendis",           "805678901V",   "Wattala",      "Gampaha"),
    ("mahesh",    "Mahesh Karunaratne",      "750987654V",   "Battaramulla", "Colombo"),
    ("nimesha",   "Nimesha Alwis",           "199780301234", "Rajagiriya",   "Colombo"),
    ("upul",      "Upul Dissanayake",        "680567890V",   "Kegalle",      "Kandy"),
    ("shirani",   "Shirani Gamage",          "715432109V",   "Negombo",      "Negombo"),
    ("hasitha",   "Hasitha Abeysekara",      "199312009876", "Homagama",     "Colombo"),
    ("ishani",    "Ishani Rodrigo",          "198955501234", "Ja-Ela",       "Gampaha"),
    ("gayan",     "Gayan Liyanage",          "830234567V",   "Kalutara",     "Colombo"),
    ("sameera",   "Sameera Wijesinghe",      "199405607788", "Kiribathgoda", "Gampaha"),
    ("kumudini",  "Kumudini Samarakoon",     "695678123V",   "Kandy",        "Kandy"),
]
# Customers who only own estimates or fill the book (no transcript).
EXTRA = [
    ("ruwan",    "Ruwan Senarath",       "790312345V",   "Piliyandala",  "Colombo"),
    ("malini",   "Malini Edirisinghe",   "776655443V",   "Horana",       "Colombo"),
    ("thilina",  "Thilina Jayasekara",   "199108803456", "Ambalangoda",  "Galle"),
    ("prasanna", "Prasanna Weerakoon",   "810456789V",   "Kurunegala",   "Kurunegala"),
    ("nadeeka",  "Nadeeka Fonseka",      "199367701234", "Negombo",      "Negombo"),
    ("charitha", "Charitha Ranaweera",   "198724506677", "Kandy",        "Kandy"),
    ("asanka",   "Asanka Mudalige",      "820987123V",   "Matara",       "Matara"),
    ("dinusha",  "Dinusha Kariyawasam",  "199659908765", "Gampaha",      "Gampaha"),
    ("janaka",   "Janaka Rajapaksha",    "730123987V",   "Avissawella",  "Colombo"),
    ("menaka",   "Menaka Gunawardena",   "199452203210", "Kalmunai",     "Batticaloa"),
    ("kavindu",  "Kavindu Herath",       "200011204455", "Kandy",        "Kandy"),
    ("roshini",  "Roshini Thambiah",     "785512340V",   "Jaffna",       "Jaffna"),
    ("isuru",    "Isuru Weerasinghe",    "199820506611", "Moratuwa",     "Colombo"),
    ("lakmal",   "Lakmal Peiris",        "840765432V",   "Chilaw",       "Negombo"),
    ("fathima",  "Fathima Rizwan",       "199183404321", "Beruwala",     "Colombo"),
]
CUSTOMERS = NAMED + EXTRA

# ---------------------------------------------------------------------------
# Policies: (policy_no, customer key, product, sum_assured, premium, start, end, status)
# ---------------------------------------------------------------------------
LIFE = "Shield Life Protect"
LIFE_H = "Shield Life Protect with Hospital Rider"
COMP = "Shield Motor Comprehensive"
TP = "Shield Motor Third Party"

POLICIES = [
    # Life policies named in the transcripts
    ("LSL-10021", "sunil",     LIFE,   2500000, 18500, "2019-12-01", "2039-12-01", "ACTIVE"),
    ("LSL-10034", "chamari",   LIFE,   1500000, 12000, "2018-06-15", "2038-06-15", "LAPSED"),
    ("LSL-10045", "tharushi",  LIFE,   3000000, 22750, "2022-01-15", "2047-01-15", "ACTIVE"),
    ("LSL-10052", "dilrukshi", LIFE,   2000000, 16800, "2020-03-10", "2040-03-10", "ACTIVE"),
    ("LSL-10056", "priyantha", LIFE,   5000000, 36000, "2016-08-01", "2036-08-01", "ACTIVE"),
    ("LSL-10057", "priyantha", LIFE,   1000000,  9500, "2021-08-01", "2041-08-01", "ACTIVE"),
    ("LSL-10063", "lalith",    LIFE,   1500000, 14200, "2015-11-20", "2030-11-20", "ACTIVE"),
    ("LSL-10072", "sarath",    LIFE_H, 2000000, 24600, "2017-05-05", "2032-05-05", "ACTIVE"),
    ("LSL-10080", "anoma",     LIFE_H, 1500000, 19900, "2023-02-01", "2043-02-01", "ACTIVE"),
    ("LSL-10088", "upul",      LIFE,   2500000, 21000, "2014-09-12", "2034-09-12", "ACTIVE"),
    ("LSL-10091", "shirani",   LIFE,   1000000, 11500, "2020-12-05", "2040-12-05", "ACTIVE"),
    # Motor policies named in the transcripts or used by estimates
    ("LSM-20007", "kasun",     COMP,   4200000, 64200, "2025-12-15", "2026-12-15", "ACTIVE"),
    ("LSM-20011", "ajith",     COMP,   3800000, 57500, "2026-04-01", "2027-04-01", "ACTIVE"),
    ("LSM-20015", "nuwan",     COMP,   4600000, 58900, "2026-06-20", "2027-06-20", "ACTIVE"),
    ("LSM-20018", "rohan",     COMP,   5200000, 71800, "2026-02-10", "2027-02-10", "ACTIVE"),
    ("LSM-20022", "dhammika",  COMP,   4900000, 47300, "2026-03-01", "2027-03-01", "ACTIVE"),
    ("LSM-20024", "rasika",    COMP,   3500000, 52400, "2026-05-15", "2027-05-15", "ACTIVE"),
    ("LSM-20026", "chathura",  COMP,   6100000, 83900, "2026-07-01", "2027-07-01", "ACTIVE"),
    ("LSM-20027", "mahesh",    COMP,   4400000, 61000, "2026-01-20", "2027-01-20", "ACTIVE"),
    ("LSM-20030", "nimesha",   COMP,   3900000, 55600, "2026-08-05", "2027-08-05", "ACTIVE"),
    ("LSM-20041", "sanduni",   COMP,   3600000, 49800, "2026-02-25", "2027-02-25", "ACTIVE"),
    ("LSM-20033", "ruwan",     COMP,   5600000, 76300, "2026-03-18", "2027-03-18", "ACTIVE"),
    ("LSM-20035", "thilina",   COMP,   4100000, 58200, "2026-05-02", "2027-05-02", "ACTIVE"),
    ("LSM-20037", "prasanna",  COMP,   7300000, 98400, "2026-06-11", "2027-06-11", "ACTIVE"),
    ("LSM-20039", "charitha",  COMP,   3300000, 47900, "2026-01-08", "2027-01-08", "ACTIVE"),
    ("LSM-20043", "asanka",    COMP,   4800000, 66100, "2026-09-01", "2027-09-01", "ACTIVE"),
    ("LSM-20045", "nadeeka",   COMP,   2900000, 42700, "2026-04-22", "2027-04-22", "ACTIVE"),
    ("LSM-20048", "janaka",    COMP,   3700000, 53300, "2025-07-14", "2026-07-14", "LAPSED"),
]
# Fill the book to 35 life and 25 motor policies.
_life_fill = ["hasitha", "ishani", "gayan", "sameera", "kumudini", "malini", "dinusha",
              "menaka", "kavindu", "roshini", "isuru", "lakmal", "fathima", "ruwan",
              "thilina", "prasanna", "charitha", "asanka", "nadeeka", "janaka",
              "kasun", "nuwan", "rohan", "nimesha"]
for i, cust in enumerate(_life_fill):
    status = "LAPSED" if i in (5, 17) else "ACTIVE"
    POLICIES.append((f"LSL-{10100 + i * 3}", cust, LIFE, 1000000 + (i % 5) * 500000,
                     9000 + (i % 7) * 2100, f"20{16 + i % 9}-{1 + i % 12:02d}-10",
                     f"20{36 + i % 9}-{1 + i % 12:02d}-10", status))
for i, cust in enumerate(["malini", "kavindu", "lakmal", "fathima"]):
    POLICIES.append((f"LSM-{20050 + i * 2}", cust, TP, None, 11800 + i * 900,
                     "2026-02-01", "2027-02-01", "ACTIVE"))

# ---------------------------------------------------------------------------
# Vehicles: one per motor policy. (reg_no, policy_no, make, model, year, chassis)
# ---------------------------------------------------------------------------
VEHICLES = [
    ("WP CAB-4521", "LSM-20007", "Toyota",     "Aqua",        2017, "NHP10-6123451"),
    ("WP CAR-6612", "LSM-20011", "Nissan",     "Sunny",       2015, "N17-0457712"),
    ("SP KX-7788",  "LSM-20015", "Honda",      "Vezel",       2016, "RU3-1209934"),
    ("WP KA-3344",  "LSM-20018", "Toyota",     "Axio",        2018, "NKE165-7712340"),
    ("SP CBF-7120", "LSM-20022", "Toyota",     "Premio",      2017, "NZT260-3304512"),
    ("WP CAS-2290", "LSM-20024", "Suzuki",     "Swift",       2019, "ZC83S-1102298"),
    ("WP CBK-5507", "LSM-20026", "Honda",      "CR-V",        2020, "RW1-1004567"),
    ("WP CAJ-8813", "LSM-20027", "Toyota",     "Vitz",        2016, "KSP130-2258817"),
    ("WP CBD-4419", "LSM-20030", "Nissan",     "X-Trail",     2018, "HT32-1103390"),
    ("CP PH-3310",  "LSM-20041", "Suzuki",     "Wagon R",     2019, "MH55S-2873310"),
    ("WP CBN-1276", "LSM-20033", "Mitsubishi", "Outlander",   2019, "GG2W-0412276"),
    ("SP CAD-6640", "LSM-20035", "Toyota",     "Corolla",     2017, "ZRE172-6640123"),
    ("NW CBP-9081", "LSM-20037", "Toyota",     "Land Cruiser Prado", 2018, "TRJ150-0090811"),
    ("CP KQ-5532",  "LSM-20039", "Honda",      "Fit",         2015, "GP5-3155320"),
    ("SP CBA-2718", "LSM-20043", "Hyundai",    "Tucson",      2019, "TL-2718340"),
    ("WP CAX-3905", "LSM-20045", "Perodua",    "Axia",        2018, "B200-3905661"),
    ("WP CAD-1187", "LSM-20048", "Toyota",     "Yaris",       2016, "NSP152-1187009"),
    ("WP KD-4410",  "LSM-20050", "Suzuki",     "Alto",        2014, "HA36S-4410022"),
    ("CP CAE-7302", "LSM-20052", "Honda",      "Grace",       2016, "GM4-7302118"),
    ("NW KN-6158",  "LSM-20054", "Toyota",     "Allion",      2015, "NZT260-6158044"),
    ("WP CBG-8876", "LSM-20056", "Nissan",     "Leaf",        2017, "ZE0-8876213"),
]
# Four more comprehensive policies, each with a car, bring motor to 25.
for i, (cust, reg, make, model, year) in enumerate([
        ("dinusha", "WP CAM-3021", "Kia", "Picanto", 2017), ("menaka", "EP CAH-1194", "Toyota", "Passo", 2016),
        ("roshini", "NP CBE-7703", "Honda", "Insight", 2015), ("isuru", "WP CAQ-4482", "Suzuki", "Celerio", 2018)]):
    no = f"LSM-{20060 + i * 2}"
    POLICIES.append((no, cust, COMP, 2800000 + i * 400000, 41000 + i * 3500, "2026-03-01", "2027-03-01", "ACTIVE"))
    VEHICLES.append((reg, no, make, model, year, f"CH{year}-{3021 + i * 1111}"))

# ---------------------------------------------------------------------------
# Existing claims CLM-26-0001 to 0010: (claim_no, policy_no, reg_no or None,
# incident, type, status, amount). Statuses follow what the callers say.
# ---------------------------------------------------------------------------
CLAIMS = [
    ("CLM-26-0001", "LSM-20033", "WP CBN-1276", "2026-02-14", "ACCIDENT", "PAID",      185000),
    ("CLM-26-0002", "LSL-10072", None,          "2026-03-02", "HOSPITAL", "PAID",       96000),
    ("CLM-26-0003", "LSM-20027", "WP CAJ-8813", "2026-06-19", "ACCIDENT", "PAID",      142500),  # CALL-025 overcharge complaint
    ("CLM-26-0004", "LSM-20011", "WP CAR-6612", "2026-10-12", "ACCIDENT", "ASSESSING", 210000),  # CALL-009 status
    ("CLM-26-0005", "LSM-20039", "CP KQ-5532",  "2026-07-30", "ACCIDENT", "REJECTED",   64000),
    ("CLM-26-0006", "LSM-20024", "WP CAS-2290", "2026-10-20", "ACCIDENT", "ASSESSING",  88000),  # CALL-024 assessor no-show
    ("CLM-26-0007", "LSM-20018", "WP KA-3344",  "2026-09-08", "ACCIDENT", "APPROVED",  132000),  # CALL-014 awaiting payment
    ("CLM-26-0008", "LSL-10045", None,          "2026-10-05", "HOSPITAL", "OPEN",       45000),
    ("CLM-26-0009", "LSL-10080", None,          "2026-09-21", "HOSPITAL", "REJECTED",   78000),  # CALL-015 rejected
    ("CLM-26-0010", "LSM-20026", "WP CBK-5507", "2026-11-01", "ACCIDENT", "ASSESSING", 305000),  # CALL-016 new, assessing
]

# ---------------------------------------------------------------------------
# Garage estimates. `written_total` is what the paper says; the line items may
# not add up to it (E03). `kind` drives how the image is rendered.
# Expected checks: required fields, line items add up, reg matches an ACTIVE
# motor policy. Any failure -> NEEDS_REVIEW.
# ---------------------------------------------------------------------------
ESTIMATES = [
    dict(id="E01", kind="clean", garage="Dulanjana Auto Works", town="Maharagama",
         phone="011 284 5521", est_no="DAW/26/0412", date="2026-10-27", reg="WP CAB-4521",
         items=[("Rear bumper (genuine)", 1, 48500), ("Rear bumper brackets", 2, 3200),
                ("Tail lamp assembly, left", 1, 21800), ("Panel beating, boot lid", 1, 18000),
                ("Painting, rear bumper and boot lid", 1, 32000), ("Labour", 1, 12500)],
         claim="CLM-26-0011"),
    dict(id="E02", kind="clean", garage="Galle Motor Engineers", town="Galle",
         phone="091 223 7764", est_no="GME-2026-1187", date="2026-10-28", reg="SP KX-7788",
         items=[("Front bumper cover", 1, 62500), ("Headlamp assembly, right", 1, 74000),
                ("Radiator support", 1, 18900), ("Front grille", 1, 15600),
                ("Painting, front bumper", 1, 26000), ("Labour", 1, 18500)],
         claim="CLM-26-0012"),
    dict(id="E03", kind="handwritten_total", garage="Hill Capital Auto Care", town="Kandy",
         phone="081 238 4410", est_no="HCA-0973", date="2026-10-29", reg="CP PH-3310",
         items=[("Left front door shell", 1, 46000), ("Side mirror, left", 1, 14500),
                ("Door trim and clips", 1, 6500), ("Painting, left front door", 1, 24000),
                ("Wheel alignment", 1, 3500), ("Labour", 1, 24000)],
         written_total=145000, claim="CLM-26-0013"),
    dict(id="E04", kind="clean", garage="Ruhuna Auto Clinic", town="Matara",
         phone="041 222 6390", est_no="RAC/1544", date="2026-10-21", reg="SP CBA-2718",
         items=[("Front windscreen", 1, 58000), ("Windscreen moulding", 1, 6400),
                ("Wiper arm, driver side", 1, 4800), ("Labour", 1, 7500)]),
    dict(id="E05", kind="clean", garage="Negombo Body Shop", town="Negombo",
         phone="031 223 9045", est_no="NBS-26-338", date="2026-10-23", reg="WP CAX-3905",
         items=[("Right rear door shell", 1, 38500), ("Door handle, outer", 1, 4200),
                ("Panel beating, rear quarter", 1, 15000), ("Painting, two panels", 1, 28000),
                ("Labour", 1, 11000)]),
    dict(id="E06", kind="clean", garage="Kurunegala Motor Works", town="Kurunegala",
         phone="037 222 5187", est_no="KMW 2026/702", date="2026-10-24", reg="NW CBP-9081",
         items=[("Front bumper (genuine)", 1, 135000), ("Fog lamp, left", 1, 28500),
                ("Bull bar bracket", 2, 9800), ("Painting, front bumper", 1, 38000),
                ("Labour", 1, 22500)]),
    dict(id="E07", kind="clean", garage="Ambalangoda Auto Repairs", town="Ambalangoda",
         phone="091 225 8812", est_no="AAR-0219", date="2026-10-25", reg="SP CAD-6640",
         items=[("Bonnet", 1, 52000), ("Bonnet hinges", 2, 5400),
                ("Painting, bonnet", 1, 22000), ("Labour", 1, 9500)]),
    dict(id="E08", kind="clean", garage="Avissawella Auto Point", town="Avissawella",
         phone="036 222 1478", est_no="AAP/26/091", date="2026-10-26", reg="WP CAD-1187",
         items=[("Rear bumper", 1, 32500), ("Reverse sensor", 2, 7800),
                ("Painting, rear bumper", 1, 18000), ("Labour", 1, 8500)]),   # policy LAPSED
    dict(id="E09", kind="clean", garage="Colombo City Motors", town="Colombo 10",
         phone="011 269 3302", est_no="CCM-55120", date="2026-10-26", reg="WP KM-5521",
         items=[("Side mirror, right", 1, 17500), ("Front door, right, panel beating", 1, 14000),
                ("Painting, right front door", 1, 21000), ("Labour", 1, 6500)]),   # no policy
    dict(id="E10", kind="skewed_photo", garage="Kelaniya Auto Care", town="Kelaniya",
         phone="011 291 4456", est_no="KAC-2026-077", date="2026-10-30", reg="WP CBN-1276",
         items=[("Rear windscreen", 1, 64000), ("Rear wiper motor", 1, 18500),
                ("Labour", 1, 8000)]),
    dict(id="E11", kind="stamped", garage="Peradeniya Motor Engineers", town="Peradeniya",
         phone="081 238 7720", est_no="PME/442", date="2026-10-30", reg="CP KQ-5532",
         items=[("Front bumper cover", 1, 41000), ("Headlamp assembly, left", 1, 36500),
                ("Painting, front bumper", 1, 22000), ("Labour", 1, 10500)]),
    dict(id="E12", kind="fuel_bill", garage="Lanka Filling Station (Kandy Rd)", town="Kadawatha",
         phone="011 292 1188", est_no="INV 884213", date="2026-10-28", reg=None,
         items=[("Petrol 92 Octane, 32.5 L", 1, 9945)]),
]


def policy(no):
    return next(p for p in POLICIES if p[0] == no)


def vehicle(reg):
    return next((v for v in VEHICLES if v[0] == reg), None)


def norm_reg(reg):
    """Compare registration numbers without spaces or hyphens (WP CAB-4521 = WPCAB4521)."""
    return re.sub(r"[\s-]", "", reg or "").upper()


def expected_checks(e):
    total = e.get("written_total", sum(q * p for _, q, p in e["items"]))
    items_sum = sum(q * p for _, q, p in e["items"])
    is_estimate = e["kind"] != "fuel_bill"
    v = vehicle(e["reg"]) if e["reg"] else None
    active = bool(v and policy(v[1])[7] == "ACTIVE" and policy(v[1])[1:3] and policy(v[1])[0].startswith("LSM"))
    checks = {
        "required_fields": is_estimate,
        "items_add_up": items_sum == total,
        "active_motor_policy": active,
    }
    return checks, ("AUTO_OK" if all(checks.values()) else "NEEDS_REVIEW")


def truth(e):
    """The JSON the extraction should return for this image (same shape as the prompt asks for)."""
    total = e.get("written_total", sum(q * p for _, q, p in e["items"]))
    v = vehicle(e["reg"]) if e["reg"] else None
    checks, status = expected_checks(e)
    return {
        "document_type": "OTHER" if e["kind"] == "fuel_bill" else "GARAGE_ESTIMATE",
        "garage_name": e["garage"],
        "garage_town": e["town"],
        "estimate_no": e["est_no"],
        "estimate_date": e["date"],
        "reg_no": e["reg"],
        "vehicle": f"{v[2]} {v[3]}" if v else None,
        "line_items": [{"description": d, "qty": q, "unit_price_lkr": p, "amount_lkr": q * p}
                       for d, q, p in e["items"]],
        "total_lkr": total,
        "expected": {"checks": checks, "review_status": status, "claim_no": e.get("claim")},
    }


def check_spec():
    """Every ID a transcript mentions must exist in this spec."""
    calls = json.loads((HERE / "calls" / "transcripts.json").read_text(encoding="utf-8"))
    policies = {p[0] for p in POLICIES}
    regs = {v[0] for v in VEHICLES}
    claims = {c[0] for c in CLAIMS} | {e["claim"] for e in ESTIMATES if e.get("claim")}
    nics = {c[2] for c in CUSTOMERS}
    problems = []
    for call in calls:
        text = call["transcript"]
        for ref in re.findall(r"LS[LM]-\d+", text):
            if ref not in policies: problems.append(f"{call['call_id']}: policy {ref}")
        for ref in re.findall(r"CLM-26-\d{4}", text):
            if ref not in claims: problems.append(f"{call['call_id']}: claim {ref}")
        for ref in re.findall(r"\b[A-Z]{2} [A-Z]{2,3}-\d{4}\b", text):
            if ref not in regs: problems.append(f"{call['call_id']}: vehicle {ref}")
        for ref in re.findall(r"\b(\d{9}[VX]|\d{12})\b", text):
            if ref not in nics: problems.append(f"{call['call_id']}: NIC {ref}")
    life = sum(p[0].startswith("LSL") for p in POLICIES)
    motor = sum(p[0].startswith("LSM") for p in POLICIES)
    assert len({c[2] for c in CUSTOMERS}) == len(CUSTOMERS), "duplicate NIC"
    assert len({p[0] for p in POLICIES}) == len(POLICIES), "duplicate policy_no"
    return problems, dict(customers=len(CUSTOMERS), life=life, motor=motor,
                          vehicles=len(VEHICLES), claims=len(CLAIMS))


if __name__ == "__main__":
    problems, counts = check_spec()
    print(counts)
    print("problems:", problems or "none")
    for e in ESTIMATES:
        t = truth(e)
        print(e["id"], e["reg"], t["total_lkr"], t["expected"]["review_status"], t["expected"]["checks"])
