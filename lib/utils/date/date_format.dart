String formatDate(DateTime? date) {
  if (date == null) return 'Unknown';
  return '${date.day}/${date.month}/${date.year}';
}
