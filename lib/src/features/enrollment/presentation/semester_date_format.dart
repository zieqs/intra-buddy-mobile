const _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatSemesterDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

String formatSemesterRange(DateTime start, DateTime end) {
  return '${formatSemesterDate(start)} – ${formatSemesterDate(end)}';
}
