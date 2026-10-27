import 'dart:math';

import '../../features/admissions/models/patient_stay.dart';

class DemoSeed {
  static const List<String> _indianNames = [
    'Priya Sharma',
    'Anita Patel',
    'Kavita Singh',
    'Meera Joshi',
    'Sunita Reddy',
    'Rani Gupta',
    'Lakshmi Iyer',
    'Savita Desai',
    'Geeta Verma',
    'Rekha Nair',
    'Suman Kapoor',
    'Aarti Menon',
    'Poonam Rao',
    'Neha Khanna',
    'Kiran Malhotra',
    'Divya Saxena',
    'Rashmi Bansal',
    'Shweta Choudhary',
    'Preeti Mishra',
    'Nisha Ahuja',
    'Sneha Bhatia',
    'Deepa Kulkarni',
    'Ritu Pillai',
    'Vandana Srinivasan',
    'Anjali Krishnan',
    'Komal Prasad',
    'Beena Narayan',
    'Lata Verghese',
    'Mala Naidu',
    'Shanti Iyengar',
    'Usha Mukherjee',
    'Saroja Devi',
    'Radha Krishnamurthy',
    'Kamala Swaminathan',
    'Vijaya Rajan',
    'Savitri Pillai',
    'Gauri Nambiar',
    'Indira Menon',
    'Padma Subramanian',
    'Lalitha Krishnan',
    'Meenakshi Seshadri',
    'Jayalakshmi Iyer',
    'Mahalakshmi Venkataraman',
    'Bhavani Ranganathan',
    'Durga Parameswaran',
    'Rukmini Balasubramanian',
    'Parvathi Sivaraman',
    'Lakshmi Narayanan',
    'Saraswathi Gopalakrishnan',
    'Annapurna Chandrasekhar',
    'Tanvi Sharma',
    'Riya Patel',
    'Ayesha Khan',
    'Fatima Sheikh',
    'Zoya Ahmed',
    'Hina Siddiqui',
    'Sarah Khan',
    'Nadia Hussain',
    'Zara Ali',
    'Mariam Malik',
    'Heena Qureshi',
    'Rukhsar Ansari',
    'Sameera Khan',
    'Tasneem Fatima',
    'Afreen Begum',
    'Nusrat Jahan',
    'Rashida Khan',
    'Zeenat Ali',
    'Shabana Begum',
    'Khurshid Ahmed',
    'Jahanara Sheikh',
    'Mehrunissa Khan',
    'Naseem Banu',
    'Qamar Jahan',
    'Saira Begum',
    'Razia Sultan',
    'Noor Jahan',
    'Zohra Begum',
    'Salma Khan',
    'Farida Ahmed',
    'Ruqaiya Khan',
    'Hafiza Begum',
    'Mahjabeen Khan',
    'Mumtaz Jahan',
    'Parveen Akhtar',
    'Zeenat Aman',
    'Sharmila Tagore',
    'Hema Malini',
    'Rekha Bhan',
    'Jaya Bhaduri',
    'Moushumi Chatterjee',
    'Rakhee Gulzar',
    'Shabana Azmi',
    'Smita Patil',
    'Deepti Naval',
    'Naseeruddin Shah',
    'Shabana Azmi',
    'Saira Banu',
    'Waheeda Rehman',
    'Madhubala',
    'Meena Kumari',
    'Nargis',
    'Suraiya',
    'Noor Jehan',
    'Kundan Lal Saigal',
    'Mohan',
    'Rajesh',
    'Amitabh',
    'Dharmendra',
    'Jeetendra',
    'Shashi',
    'Vinod',
    'Rishi',
    'Sanjeev',
    'Mohan',
  ];

  static const List<String> _deliveryPlaces = [
    'Munshi',
    'Bavishi',
    'Sheth',
    'Amin',
    'Mayflower',
    'Rupal Parikh',
    'Sushrusha hospital',
    'Dr.Akshay Shah',
    'Dr. Kiran Desai',
    'Dr. Suresh Kothari',
    'Sunflower',
    'Dr. Seema Talati',
    'Dr. Bharat Parikh',
    'Dr. Prashant Acharya',
    'Dr. Ashish Nanavati',
    'Zydus Hospital',
    'Apollo Hospital',
    'Civil Hospital',
    'SGVP',
    'CIMS',
    'Sterling Hospital',
    'Narayana Hrudayalaya',
  ];

  static const List<String> _districts = [
    'Ahmedabad',
    'Gandhinagar',
    'Surat',
    'Vadodara',
    'Rajkot',
    'Bhavnagar',
    'Jamnagar',
    'Junagadh',
    'Surendranagar',
    'Anand',
    'Kheda',
    'Patan',
    'Sabarkantha',
    'Banaskantha',
    'Mahesana',
    'Kutch',
    'Dang',
    'Navsari',
    'Valsad',
    'Tapi',
    'Bharuch',
    'Narmada',
    'Panchmahal',
    'Dahod',
    'Aravalli',
    'Botad',
    'Chhota Udepur',
    'Devbhoomi Dwarka',
    'Gir Somnath',
    'Morbi',
  ];

  static const List<String> _areas = [
    'Navrangpura',
    'Paldi',
    'Bodakdev',
    'Prahlad Nagar',
    'Satellite',
    'Vastrapur',
    'Maninagar',
    'Navajivan',
    'Khanpur',
    'Lal Darwaja',
    'Ashram Road',
    'C.G. Road',
    'Thaltej',
    'Shahibaug',
    'Ambawadi',
    'Ellisbridge',
    'Usmanpura',
    'Naroda',
    'Vatva',
    'Gomtipur',
    'Raipur',
    'Dariapur',
    'Kalupur',
    'Sherkot',
    'Saraspur',
    'Behrampura',
    'Kubernagar',
    'Odhav',
    'Vejalpur',
    'Jodhpur',
    'Bapunagar',
    'Rakhial',
    'Isanpur',
    'Nikol',
    'Hathijan',
    'Vastral',
    'Amraiwadi',
    'Madhupura',
    'Kankaria',
    'Bapunagar',
  ];

  static int _randomInt(int min, int max) =>
      min + Random().nextInt(max - min + 1);

  static String _randomPhoneNumber() {
    final prefixes = ['6', '7', '8', '9'];
    final prefix = prefixes[_randomInt(0, 3)];
    final rest = List.generate(9, (_) => _randomInt(0, 9).toString()).join();
    return '$prefix$rest';
  }

  static String _randomPin() {
    return List.generate(6, (_) => _randomInt(0, 9).toString()).join();
  }

  static DateTime _randomDate(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    final randomDays = _randomInt(0, diff);
    return start.add(Duration(days: randomDays));
  }

  static List<PatientStay> generateSeedData() {
    final random = Random(42); // Fixed seed for determinism
    final patients = <PatientStay>[];

    final now = DateTime.now();
    final threeYearsAgo = now.subtract(const Duration(days: 3 * 365));

    // Keep the demo dataset small enough to explore without long lists.
    for (int i = 0; i < 24; i++) {
      final doa = i < 4
          ? now.subtract(Duration(days: random.nextInt(7)))
          : _randomDate(threeYearsAgo, now);
      final stayLength = _randomInt(1, 7);
      final dod = i < 4
          ? null
          : _randomInt(0, 10) <
                8 // 80% discharged
          ? doa.add(Duration(days: stayLength))
          : null;

      final isTwin = i < 2;
      final isTriplet = i >= 2 && i < 5;
      final name = isTwin
          ? 'Demo Twin Mother'
          : isTriplet
          ? 'Demo Triplet Mother'
          : _indianNames[random.nextInt(_indianNames.length)];
      final prefix = isTwin || isTriplet
          ? Prefix.bo
          : [Prefix.so, Prefix.do_, Prefix.bo][random.nextInt(3)];
      final birthType = isTwin
          ? BirthType.twin
          : isTriplet
          ? BirthType.triplet
          : BirthType.single;
      final babySuffix = isTwin
          ? (i == 0 ? 'A' : 'B')
          : isTriplet
          ? ['A', 'B', 'C'][i - 2]
          : null;
      final displayedPrefix = switch (prefix) {
        Prefix.so => 'S/O',
        Prefix.do_ => 'D/O',
        Prefix.bo => 'B/O',
      };
      final relation = Relation.values[random.nextInt(Relation.values.length)];
      final relation2 = random.nextBool()
          ? Relation.values[random.nextInt(Relation.values.length)]
          : null;

      final patient = PatientStay(
        id: 'seed_$i',
        serialNo: i + 1,
        financialYear: _financialYearForDate(doa),
        prefix: prefix,
        mothersName: name,
        babyName: babySuffix == null
            ? '$displayedPrefix $name'
            : 'B/O $name - $babySuffix',
        branch: i.isEven ? Branch.arpanMother : Branch.arpanViolet,
        admissionType: i.isEven ? AdmissionType.inborn : AdmissionType.outborn,
        admissionHistory: i % 3 == 0
            ? AdmissionHistory.firstAdmission
            : AdmissionHistory.reAdmission,
        birthType: birthType,
        doa: doa,
        dod: dod,
        stay: stayLength,
        contactNumber: _randomPhoneNumber(),
        contactRelation: relation,
        contactNumber2: random.nextBool() ? _randomPhoneNumber() : null,
        contactRelation2: relation2,
        address: '${_areas[random.nextInt(_areas.length)]} Area',
        street: 'Street ${random.nextInt(100)}',
        area: _areas[random.nextInt(_areas.length)],
        city: 'AHMEDABAD',
        pin: _randomPin(),
        del: _deliveryPlaces[random.nextInt(_deliveryPlaces.length)],
        status: random.nextBool() ? PatientStatus.alive : null,
        // Discharge fields (only if discharged)
        ipNo: dod != null
            ? '${random.nextInt(999)}${doa.day.toString().padLeft(2, '0')}${doa.month.toString().padLeft(2, '0')}${doa.year}'
            : null,
        sex: Sex.values[random.nextInt(Sex.values.length)],
        state: 'Gujarat',
        district: _districts[random.nextInt(_districts.length)],
        dateOfBirth: doa.subtract(Duration(days: random.nextInt(30))),
        placeOfDeliveryDischarge:
            _deliveryPlaces[random.nextInt(_deliveryPlaces.length)],
        gestAgeWeeks: random.nextInt(10) + 28, // 28-38 weeks
        gestAgeDays: random.nextInt(7),
        birthWeight: (random.nextDouble() * 3 + 0.5).toDouble(), // 0.5-3.5 kg
        admissionWeight: (random.nextDouble() * 3 + 0.5).toDouble(),
        weightPercentile: WeightPercentile
            .values[random.nextInt(WeightPercentile.values.length)],
        dischargeWeight: dod != null
            ? (random.nextDouble() * 3 + 0.5).toDouble()
            : null,
        headCircumference: (random.nextDouble() * 10 + 25).toDouble(),
        maternalMorbidities: random.nextBool()
            ? [
                'PIH',
                'PROM',
                'APH',
                'Meconium stained liquor',
                'Diabetes',
                'Hypothyroidism',
              ].where((_) => random.nextBool()).toList()
            : null,
        ans: ANS.values[random.nextInt(ANS.values.length)],
        antentalScan: random.nextBool()
            ? [
                'Normal',
                'Oligohydroamnios',
                'AEDF/REDF',
                'Brain sparing effect',
                'Polyhydroamnios',
              ].where((_) => random.nextBool()).toList()
            : null,
        modeOfDelivery:
            ModeOfDelivery.values[random.nextInt(ModeOfDelivery.values.length)],
        resuscitationAtBirth: random.nextBool()
            ? [
                'None',
                'Oxygen',
                'Bag and Mask',
                'Bag and Tube',
                'Drugs',
              ].where((_) => random.nextBool()).toList()
            : null,
        respiratorySystem: random.nextBool()
            ? [
                'TTN',
                'HMD',
                'MAS',
                'Pneumothorax',
              ].where((_) => random.nextBool()).toList()
            : null,
        cardiovascularSystem: random.nextBool() ? 'Normal' : null,
        sepsis: ['No Sepsis', 'Culture -ve', 'Culture +ve'][random.nextInt(3)],
        organism: random.nextBool() ? 'E. coli' : null,
        feeding: random.nextBool()
            ? [
                'NEC',
                'GER',
                'Feed Intolerance',
              ].where((_) => random.nextBool()).toList()
            : null,
        rtfStarted: random.nextBool() ? 'Day ${random.nextInt(5) + 1}' : null,
        fullFeedsReached: random.nextBool()
            ? 'Day ${random.nextInt(10) + 5}'
            : null,
        surfactant: Surfactant.values[random.nextInt(Surfactant.values.length)],
        ventilation: random.nextBool()
            ? [
                'CPAP',
                'HHHFNC',
                'NIMV',
                'HFOV',
                'Conventinal',
              ].where((_) => random.nextBool()).toList()
            : null,
        bpd: BPD.values[random.nextInt(BPD.values.length)],
        probiotics: random.nextBool(),
        bloodTransfusion: random.nextBool(),
        rop: ROP.values[random.nextInt(ROP.values.length)],
        usgHead: random.nextBool() ? 'Normal' : null,
        picc: random.nextBool(),
        user: 'Demo User',
        statusOk: true,
      );

      patients.add(patient);
    }

    return patients;
  }

  static int _financialYearForDate(DateTime date) =>
      date.month >= 4 ? date.year : date.year - 1;
}
