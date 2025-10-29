import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/earthquake_filter.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/custom_snackbar.dart';

class FiltersSettingsPage extends ConsumerStatefulWidget {
  const FiltersSettingsPage({super.key});

  @override
  ConsumerState<FiltersSettingsPage> createState() => _FiltersSettingsPageState();
}

class _FiltersSettingsPageState extends ConsumerState<FiltersSettingsPage> {
  EarthquakeFilterArea selectedDefaultArea = EarthquakeFilterArea.defaultArea;
  double defaultMinMagnitude = 0.0;
  int defaultDaysBack = 1;
  bool defaultUseCustomDateRange = false;
  DateTime? defaultCustomStartDate;
  DateTime? defaultCustomEndDate;

  @override
  void initState() {
    super.initState();
    // Initialize with saved default filter values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedDefaultFilter();
    });
  }

  Future<void> _loadSavedDefaultFilter() async {
    final defaultSettings = ref.read(defaultSettingsProvider);
    setState(() {
      selectedDefaultArea = defaultSettings.defaultFilter.area;
      defaultMinMagnitude = defaultSettings.defaultFilter.minMagnitude;
      defaultDaysBack = defaultSettings.defaultFilter.daysBack;
      defaultUseCustomDateRange = defaultSettings.defaultFilter.useCustomDateRange;
      defaultCustomStartDate = defaultSettings.defaultFilter.customStartDate;
      defaultCustomEndDate = defaultSettings.defaultFilter.customEndDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.defaultFilters),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.setDefaultFilters, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[300])),
            const SizedBox(height: 18),

            // Area selection
            _buildSectionTitle(l10n.geographicArea),
            const SizedBox(height: 8),
            _buildAreaSelector(l10n),
            const SizedBox(height: 24),

            // Magnitude slider
            _buildSectionTitle(l10n.minimumMagnitude),
            const SizedBox(height: 8),
            _buildMagnitudeSlider(),
            const SizedBox(height: 24),

            // Date range selection
            _buildSectionTitle(l10n.timePeriod),
            const SizedBox(height: 8),
            _buildDateRangeSelector(l10n),
            const SizedBox(height: 12),

            // Days selection (only if "Last days" is selected)
            if (!defaultUseCustomDateRange) ...[_buildSectionTitle(l10n.defaultDays), const SizedBox(height: 8), _buildDaysSelector(l10n), const SizedBox(height: 12)],

            const SizedBox(height: 12),

            // Custom Date Range (if enabled)
            if (defaultUseCustomDateRange) ...[_buildSectionTitle(l10n.customDateRange), const SizedBox(height: 8), _buildCustomDateRange(l10n), const SizedBox(height: 24)],

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.saveSettings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),

            // Reset Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _resetToDefaults,
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400], padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(l10n.resetToDefaults, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildAreaSelector(AppLocalizations l10n) {
    final viewModel = ref.watch(settingsViewModelProvider);
    final availableAreas = viewModel.getAvailableFilterAreas();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EarthquakeFilterArea>(
          value: selectedDefaultArea,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white),
          items: availableAreas.map((area) {
            return DropdownMenuItem(value: area, child: Text(area.getTranslatedName(l10n)));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedDefaultArea = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMagnitudeSlider() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: defaultMinMagnitude,
                min: 0.0,
                max: 8.0,
                divisions: 80,
                activeColor: Colors.white,
                inactiveColor: Colors.grey[700],
                onChanged: (value) {
                  setState(() {
                    defaultMinMagnitude = value;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                defaultMinMagnitude.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations l10n) {
    return Container(
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
                  defaultUseCustomDateRange = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: !defaultUseCustomDateRange ? Colors.orange : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  l10n.lastDays,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: !defaultUseCustomDateRange ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  defaultUseCustomDateRange = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: defaultUseCustomDateRange ? Colors.orange : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  l10n.customRange,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: defaultUseCustomDateRange ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector(AppLocalizations l10n) {
    final dayOptions = [
      {'days': 1, 'label': l10n.oneDay},
      {'days': 3, 'label': l10n.threeDays},
      {'days': 7, 'label': l10n.oneWeek},
      {'days': 15, 'label': l10n.twoWeeks},
      {'days': 30, 'label': l10n.oneMonth},
      {'days': 90, 'label': l10n.threeMonths},
      {'days': 180, 'label': l10n.sixMonths},
      {'days': 365, 'label': l10n.oneYear},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dayOptions.map((option) {
        final days = option['days'] as int;
        final label = option['label'] as String;
        final isSelected = defaultDaysBack == days;

        return GestureDetector(
          onTap: () {
            setState(() {
              defaultDaysBack = days;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? Colors.orange : Colors.white, width: 1),
            ),
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomDateRange(AppLocalizations l10n) {
    return Column(
      children: [
        // Start Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.startDate, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final viewModel = ref.read(settingsViewModelProvider);
                final date = await showDatePicker(
                  context: context,
                  initialDate: defaultCustomStartDate ?? DateTime.now().subtract(const Duration(days: 30)),
                  firstDate: viewModel.getMinimumDate(),
                  lastDate: viewModel.getMaximumDate(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(primary: Colors.orange, onPrimary: Colors.black, surface: Colors.black, onSurface: Colors.white),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    defaultCustomStartDate = date;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        defaultCustomStartDate != null ? '${defaultCustomStartDate!.day}/${defaultCustomStartDate!.month}/${defaultCustomStartDate!.year}' : l10n.selectDate,
                        style: TextStyle(color: Colors.grey[300], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // End Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.endDate, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final viewModel = ref.read(settingsViewModelProvider);
                final date = await showDatePicker(
                  context: context,
                  initialDate: defaultCustomEndDate ?? DateTime.now(),
                  firstDate: defaultCustomStartDate ?? viewModel.getMinimumDate(),
                  lastDate: viewModel.getMaximumDate(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(primary: Colors.orange, onPrimary: Colors.black, surface: Colors.black, onSurface: Colors.white),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    defaultCustomEndDate = date;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        defaultCustomEndDate != null ? '${defaultCustomEndDate!.day}/${defaultCustomEndDate!.month}/${defaultCustomEndDate!.year}' : l10n.selectDate,
                        style: TextStyle(color: Colors.grey[300], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Reset Date Button
        TextButton.icon(
          onPressed: () {
            setState(() {
              defaultCustomStartDate = null;
              defaultCustomEndDate = null;
            });
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(l10n.resetDates, style: const TextStyle(fontSize: 14)),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[400], padding: const EdgeInsets.symmetric(vertical: 8)),
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(settingsViewModelProvider);

    // Validate settings using ViewModel
    final dateValidation = viewModel.validateDateRange(defaultCustomStartDate, defaultCustomEndDate);
    if (dateValidation != null) {
      AnimatedSnackBarHelper.showError(context, dateValidation);
      return;
    }

    final magnitudeValidation = viewModel.validateMagnitude(defaultMinMagnitude);
    if (magnitudeValidation != null) {
      AnimatedSnackBarHelper.showError(context, magnitudeValidation);
      return;
    }

    // Create filter using ViewModel
    final newDefaultFilter = viewModel.createFilterFromSettings(
      area: selectedDefaultArea,
      minMagnitude: defaultMinMagnitude,
      daysBack: defaultDaysBack,
      customStartDate: defaultCustomStartDate,
      customEndDate: defaultCustomEndDate,
      useCustomDateRange: defaultUseCustomDateRange,
    );

    // Save to default settings provider (async)
    await ref.read(defaultSettingsProvider.notifier).setDefaultFilter(newDefaultFilter);

    // Show success message
    if (mounted) {
      AnimatedSnackBarHelper.showSuccess(context, l10n.settingsSavedSuccessfully);
    }
  }

  Future<void> _resetToDefaults() async {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(settingsViewModelProvider);
    final defaultFilter = viewModel.getDefaultFilter();

    setState(() {
      selectedDefaultArea = defaultFilter.area;
      defaultMinMagnitude = defaultFilter.minMagnitude;
      defaultDaysBack = defaultFilter.daysBack;
      defaultUseCustomDateRange = defaultFilter.useCustomDateRange;
      defaultCustomStartDate = defaultFilter.customStartDate;
      defaultCustomEndDate = defaultFilter.customEndDate;
    });

    await ref.read(defaultSettingsProvider.notifier).resetToDefaults();

    if (mounted) {
      AnimatedSnackBarHelper.showInfo(context, l10n.settingsResetToDefaults);
    }
  }
}
