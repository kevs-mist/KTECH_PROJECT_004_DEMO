import 'package:intl/intl.dart';
import '../features/admissions/models/patient_stay.dart';

enum ChartPeriod {
  yearly,
  monthly,
  daily,
}

class AggregationData {
  final String label;
  final int admissions;
  final int discharges;

  AggregationData({
    required this.label,
    required this.admissions,
    required this.discharges,
  });
}

/// Calculate financial year from a date
/// Financial year: April to March
/// April 2024 to March 2025 = 2024
int getFinancialYear(DateTime date) {
  if (date.month >= 4) {
    return date.year;
  } else {
    return date.year - 1;
  }
}

/// Get the start date of a financial year
DateTime getFinancialYearStart(int financialYear) {
  return DateTime(financialYear, 4, 1);
}

/// Get the end date of a financial year
DateTime getFinancialYearEnd(int financialYear) {
  return DateTime(financialYear + 1, 3, 31, 23, 59, 59);
}

/// Get last 5 financial years ending with current year
List<int> getLast5FinancialYears() {
  final now = DateTime.now();
  final currentFY = getFinancialYear(now);
  return List.generate(5, (i) => currentFY - 4 + i);
}

/// Get financial year label (e.g., "2024-25")
String getFinancialYearLabel(int financialYear) {
  return '$financialYear-${(financialYear + 1) % 100}';
}

/// Get month names for financial year (April to March)
List<String> getFinancialYearMonths() {
  return [
    'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar',
  ];
}

/// Get month index in financial year (0=April, 11=March)
int getFinancialMonthIndex(DateTime date) {
  if (date.month >= 4) {
    return date.month - 4;
  } else {
    return date.month + 8;
  }
}

/// Aggregate admissions by year for a list of patients
List<AggregationData> aggregateByYear(
  List<PatientStay> patients,
  List<int> financialYears,
) {
  final Map<int, AggregationData> data = {};

  for (final fy in financialYears) {
    data[fy] = AggregationData(
      label: getFinancialYearLabel(fy),
      admissions: 0,
      discharges: 0,
    );
  }

  for (final patient in patients) {
    final admissionFY = getFinancialYear(patient.doa);
    if (data.containsKey(admissionFY)) {
      data[admissionFY] = AggregationData(
        label: data[admissionFY]!.label,
        admissions: data[admissionFY]!.admissions + 1,
        discharges: data[admissionFY]!.discharges,
      );
    }

    if (patient.dod != null) {
      final dischargeFY = getFinancialYear(patient.dod!);
      if (data.containsKey(dischargeFY)) {
        data[dischargeFY] = AggregationData(
          label: data[dischargeFY]!.label,
          admissions: data[dischargeFY]!.admissions,
          discharges: data[dischargeFY]!.discharges + 1,
        );
      }
    }
  }

  return financialYears.map((fy) => data[fy]!).toList();
}

/// Aggregate admissions by month for a specific financial year
List<AggregationData> aggregateByMonth(
  List<PatientStay> patients,
  int financialYear,
) {
  final monthLabels = getFinancialYearMonths();
  final List<AggregationData> data = List.generate(
    12,
    (i) => AggregationData(
      label: monthLabels[i],
      admissions: 0,
      discharges: 0,
    ),
  );

  final fyStart = getFinancialYearStart(financialYear);
  final fyEnd = getFinancialYearEnd(financialYear);

  for (final patient in patients) {
    if ((patient.doa.isAfter(fyStart) || patient.doa.isAtSameMomentAs(fyStart)) &&
        (patient.doa.isBefore(fyEnd) || patient.doa.isAtSameMomentAs(fyEnd))) {
      final monthIndex = getFinancialMonthIndex(patient.doa);
      data[monthIndex] = AggregationData(
        label: data[monthIndex].label,
        admissions: data[monthIndex].admissions + 1,
        discharges: data[monthIndex].discharges,
      );
    }

    if (patient.dod != null &&
        (patient.dod!.isAfter(fyStart) || patient.dod!.isAtSameMomentAs(fyStart)) &&
        (patient.dod!.isBefore(fyEnd) || patient.dod!.isAtSameMomentAs(fyEnd))) {
      final monthIndex = getFinancialMonthIndex(patient.dod!);
      data[monthIndex] = AggregationData(
        label: data[monthIndex].label,
        admissions: data[monthIndex].admissions,
        discharges: data[monthIndex].discharges + 1,
      );
    }
  }

  return data;
}

/// Aggregate admissions by day for a specific month
List<AggregationData> aggregateByDay(
  List<PatientStay> patients,
  int year,
  int month,
) {
  // Calculate days in month
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final List<AggregationData> data = List.generate(
    daysInMonth,
    (i) => AggregationData(
      label: '${i + 1}',
      admissions: 0,
      discharges: 0,
    ),
  );

  for (final patient in patients) {
    if (patient.doa.year == year && patient.doa.month == month) {
      final dayIndex = patient.doa.day - 1;
      data[dayIndex] = AggregationData(
        label: data[dayIndex].label,
        admissions: data[dayIndex].admissions + 1,
        discharges: data[dayIndex].discharges,
      );
    }

    if (patient.dod != null &&
        patient.dod!.year == year &&
        patient.dod!.month == month) {
      final dayIndex = patient.dod!.day - 1;
      data[dayIndex] = AggregationData(
        label: data[dayIndex].label,
        admissions: data[dayIndex].admissions,
        discharges: data[dayIndex].discharges + 1,
      );
    }
  }

  return data;
}

/// Calculate days stayed between two dates
int calculateDaysStayed(DateTime doa, DateTime dod) {
  return dod.difference(doa).inDays;
}

/// Format date as dd MMM yyyy
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Format date as yyyyMM for discharge month
String formatYearMonth(DateTime date) {
  return DateFormat('yyyyMM').format(date);
}
