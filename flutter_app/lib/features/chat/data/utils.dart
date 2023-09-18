


bool isDifferentDay (DateTime d1, DateTime d2) => DateTime(d1.year, d1.month, d1.day).difference(DateTime(d2.year, d2.month, d2.day)).inDays != 0;
