enum ProjectViewType {
  list('List'),
  board('Board'),
  calendar('Calendar'),
  details('Details'),
  assignedUsers('Assigned Users');

  final String label;
  const ProjectViewType(this.label);

  static ProjectViewType fromString(String value) {
    return ProjectViewType.values.firstWhere(
      (type) => type.label == value,
      orElse: () => ProjectViewType.list,
    );
  }
}
