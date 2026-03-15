import 'package:f_launcher/src/common/enums/launcher_filter_enum.dart';
import 'package:f_launcher/src/features/launcher/view_models/launcher_view_model.dart';
import 'package:flutter/material.dart';

class FilterAppTypeWidget extends StatelessWidget {
  final LauncherViewModel launcherViewModel;

  const FilterAppTypeWidget({super.key, required this.launcherViewModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Select application type'),
      trailing: DropdownButton<LauncherFilterEnum>(
        value: launcherViewModel.currentFilter,
        items: LauncherFilterEnum.values.map((filter) {
          return DropdownMenuItem<LauncherFilterEnum>(
            value: filter,
            child: Text(filter.name),
          );
        }).toList(),
        onChanged: (filter) {
          if (filter != null) {
            launcherViewModel.updateFilter(filter);
          }
        },
      ),
    );
  }
}
