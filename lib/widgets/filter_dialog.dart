import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake_filter.dart';
import '../providers/earthquake_providers.dart';
import '../providers/settings_provider.dart';
import '../utils/filter_validator.dart';
import 'custom_snackbar.dart';

class FilterDialog extends ConsumerStatefulWidget {
  const FilterDialog({super.key});

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  late EarthquakeFilterArea selectedArea;
  late double minMagnitude;
  late int daysBack;
  late DateTime? customStartDate;
  late DateTime? customEndDate;
  late bool useCustomDateRange;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(filterProvider).currentFilter;
    selectedArea = currentFilter.area;
    minMagnitude = currentFilter.minMagnitude;
    daysBack = currentFilter.daysBack;
    customStartDate = currentFilter.customStartDate;
    customEndDate = currentFilter.customEndDate;
    useCustomDateRange = currentFilter.useCustomDateRange;
  }

  Widget _buildDayButton(int days, String label, AppLocalizations l10n) {
    final isSelected = daysBack == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          daysBack = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableAreas = FilterValidator.getAvailableFilterAreas();

    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      title: Text(
        l10n.filterEvents,
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.geographicArea,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EarthquakeFilterArea>(
                initialValue: selectedArea,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                items: availableAreas.map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text(area.getTranslatedName(l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedArea = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.minimumMagnitude,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: minMagnitude,
                      min: 0.0,
                      max: 8.0,
                      divisions: 80,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey[700],
                      onChanged: (value) {
                        setState(() {
                          minMagnitude = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      minMagnitude.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.timePeriod,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            useCustomDateRange = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !useCustomDateRange
                                ? Colors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.lastDays,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !useCustomDateRange
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            useCustomDateRange = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: useCustomDateRange
                                ? Colors.orange
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.customRange,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: useCustomDateRange
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (!useCustomDateRange) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDayButton(1, l10n.oneDay, l10n),
                    _buildDayButton(3, l10n.threeDays, l10n),
                    _buildDayButton(7, l10n.oneWeek, l10n),
                    _buildDayButton(15, l10n.twoWeeks, l10n),
                    _buildDayButton(30, l10n.oneMonth, l10n),
                    _buildDayButton(90, l10n.threeMonths, l10n),
                    _buildDayButton(180, l10n.sixMonths, l10n),
                    _buildDayButton(365, l10n.oneYear, l10n),
                  ],
                ),
              ],

              if (useCustomDateRange) ...[
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.startDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  customStartDate ??
                                  DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                              firstDate: FilterValidator.getMinimumDate(),
                              lastDate: FilterValidator.getMaximumDate(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.orange,
                                      onPrimary: Colors.black,
                                      surface: Colors.black,
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() {
                                customStartDate = date;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[600]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    customStartDate != null
                                        ? '${customStartDate!.day}/${customStartDate!.month}/${customStartDate!.year}'
                                        : l10n.selectDate,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.endDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: customEndDate ?? DateTime.now(),
                              firstDate:
                                  customStartDate ??
                                  FilterValidator.getMinimumDate(),
                              lastDate: FilterValidator.getMaximumDate(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.orange,
                                      onPrimary: Colors.black,
                                      surface: Colors.black,
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setState(() {
                                customEndDate = date;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[600]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    customEndDate != null
                                        ? '${customEndDate!.day}/${customEndDate!.month}/${customEndDate!.year}'
                                        : l10n.selectDate,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      customStartDate = null;
                      customEndDate = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.resetDates),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final defaultFilter = ref.read(settingsProvider).value?.defaultFilter ?? const EarthquakeFilter();

            setState(() {
              selectedArea = defaultFilter.area;
              minMagnitude = defaultFilter.minMagnitude;
              daysBack = defaultFilter.daysBack;
              useCustomDateRange = defaultFilter.useCustomDateRange;
              customStartDate = defaultFilter.customStartDate;
              customEndDate = defaultFilter.customEndDate;
            });
          },
          child: Text(
            l10n.defaultButton,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.cancel, style: const TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            if (useCustomDateRange) {
              final dateError = FilterValidator.validateDateRange(
                customStartDate,
                customEndDate,
              );
              if (dateError != null) {
                AnimatedSnackBarHelper.showError(context, dateError);
                return;
              }
            }
            final magError = FilterValidator.validateMagnitude(minMagnitude);
            if (magError != null) {
              AnimatedSnackBarHelper.showError(context, magError);
              return;
            }

            final newFilter = EarthquakeFilter(
              area: selectedArea,
              minMagnitude: minMagnitude,
              daysBack: daysBack,
              customStartDate: customStartDate,
              customEndDate: customEndDate,
              useCustomDateRange: useCustomDateRange,
            );

            ref.read(filterProvider.notifier).updateFilter(newFilter);
            ref.invalidate(earthquakesFutureProvider);

            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: Text(l10n.apply),
        ),
      ],
    );
  }
}
