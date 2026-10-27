PRAGMA foreign_keys = ON;

BEGIN IMMEDIATE;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS patient_stays (
  id TEXT PRIMARY KEY NOT NULL,
  serialNo INTEGER,
  financialYear INTEGER,
  prefix TEXT NOT NULL CHECK (prefix IN ('so', 'do_', 'bo')),
  mothersName TEXT NOT NULL,
  babyName TEXT,
  branch TEXT CHECK (branch IN ('arpanMother', 'arpanViolet')),
  admissionType TEXT CHECK (admissionType IN ('inborn', 'outborn')),
  admissionHistory TEXT CHECK (admissionHistory IN ('firstAdmission', 'reAdmission')),
  birthType TEXT CHECK (birthType IN ('single', 'twin', 'triplet')),
  doa TEXT NOT NULL,
  dod TEXT,
  stay INTEGER,
  contactNumber TEXT NOT NULL,
  contactRelation TEXT NOT NULL CHECK (contactRelation IN ('father', 'mother', 'gFather', 'uncle', 'mama', 'nana', 'nani', 'foi')),
  contactNumber2 TEXT,
  contactRelation2 TEXT CHECK (contactRelation2 IN ('father', 'mother', 'gFather', 'uncle', 'mama', 'nana', 'nani', 'foi')),
  address TEXT,
  street TEXT,
  area TEXT,
  city TEXT NOT NULL DEFAULT 'AHMEDABAD',
  pin TEXT NOT NULL,
  del TEXT NOT NULL,
  status TEXT CHECK (status IN ('alive', 'expire')),
  remarks TEXT,
  lastRemarked TEXT,
  ipNo TEXT,
  sex TEXT CHECK (sex IN ('male', 'female')),
  state TEXT DEFAULT 'Gujarat',
  district TEXT,
  dateOfBirth TEXT,
  placeOfDeliveryDischarge TEXT,
  gestAgeWeeks INTEGER,
  gestAgeDays INTEGER CHECK (gestAgeDays IS NULL OR gestAgeDays BETWEEN 0 AND 6),
  birthWeight REAL,
  admissionWeight REAL,
  weightPercentile TEXT CHECK (weightPercentile IN ('afd', 'sfd', 'lfd')),
  dischargeWeight REAL,
  headCircumference REAL,
  length REAL,
  maternalMorbidities TEXT,
  maternalMorbiditiesOther TEXT,
  ans TEXT CHECK (ans IN ('yes', 'no', 'incomplete')),
  antentalScan TEXT,
  antentalScanOther TEXT,
  modeOfDelivery TEXT CHECK (modeOfDelivery IN ('vaginal', 'cesarian', 'forceps')),
  resuscitationAtBirth TEXT,
  respiratorySystemOther TEXT,
  respiratorySystem TEXT,
  antibiotics TEXT,
  cardiovascularSystem TEXT,
  sepsisOther TEXT,
  sepsis TEXT,
  organism TEXT,
  feeding TEXT,
  feedingOther TEXT,
  rtfStarted TEXT,
  fullFeedsReached TEXT,
  surfactant TEXT CHECK (surfactant IN ('no', 'singleDose', 'multipleDose')),
  ventilation TEXT,
  bpd TEXT CHECK (bpd IN ('yes', 'no')),
  probiotics INTEGER CHECK (probiotics IS NULL OR probiotics IN (0, 1)),
  bloodTransfusion INTEGER CHECK (bloodTransfusion IS NULL OR bloodTransfusion IN (0, 1)),
  rop TEXT CHECK (rop IN ('no', 'treated', 'notTreated')),
  usgHead TEXT,
  fileName TEXT,
  adductaAngle TEXT,
  cdcHeadControl TEXT,
  cdcSitting TEXT,
  cdcStanding TEXT,
  dasiiMotorAgeAt50thCentile TEXT,
  dasiiMotorAgeAt97thCentile TEXT,
  dasiiMentalAgeAt50thCentile TEXT,
  dasiiMentalAgeAt97thCentile TEXT,
  other TEXT,
  picc INTEGER CHECK (picc IS NULL OR picc IN (0, 1)),
  user TEXT,
  statusOk INTEGER NOT NULL DEFAULT 0 CHECK (statusOk IN (0, 1)),
  dischargeType TEXT CHECK (dischargeType IN ('routine', 'expired', 'shift')),
  shiftedTo TEXT,
  shiftReason TEXT,
  UNIQUE (financialYear, serialNo)
);

CREATE INDEX IF NOT EXISTS idx_patient_stays_doa ON patient_stays (doa);
CREATE INDEX IF NOT EXISTS idx_patient_stays_dod ON patient_stays (dod);
CREATE INDEX IF NOT EXISTS idx_patient_stays_mothers_name ON patient_stays (mothersName COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_patient_stays_ip_no ON patient_stays (ipNo);

INSERT OR IGNORE INTO schema_migrations (version) VALUES (1);
PRAGMA user_version = 1;

COMMIT;