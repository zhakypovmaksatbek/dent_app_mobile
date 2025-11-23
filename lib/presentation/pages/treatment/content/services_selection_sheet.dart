import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service_item/get_service_item_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/service_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceSelectionSheet extends StatefulWidget {
  final List<ServiceResponse> initialServices;
  final Function(List<ServiceResponse>) onSelectionChanged;

  const ServiceSelectionSheet({
    super.key,
    required this.initialServices,
    required this.onSelectionChanged,
  });

  @override
  State<ServiceSelectionSheet> createState() => _ServiceSelectionSheetState();
}

class _ServiceSelectionSheetState extends State<ServiceSelectionSheet> {
  // Servis ID -> Adet eslemesi
  final Map<int, int> _counts = {};
  // Servis ID -> Servis Objesi (Referans icin)
  final Map<int, ServiceResponse> _serviceMap = {};

  @override
  void initState() {
    super.initState();
    context.read<GetServiceItemCubit>().getServiceItems();

    // Mevcut servisleri count map'ine donustur
    for (var s in widget.initialServices) {
      if (s.id != null) {
        _counts[s.id!] = (_counts[s.id!] ?? 0) + 1;
        _serviceMap[s.id!] = s;
      }
    }
  }

  void _updateCount(ServiceItem item, int delta) {
    setState(() {
      final id = item.id!;
      final current = _counts[id] ?? 0;
      final next = current + delta;

      if (next <= 0) {
        _counts.remove(id);
      } else {
        _counts[id] = next;
        // ServiceItem -> ServiceResponse donusumu
        if (!_serviceMap.containsKey(id)) {
          _serviceMap[id] = ServiceResponse(
            id: item.id,
            name: item.name,
            price: item.price?.toInt(),
          );
        }
      }
    });
  }

  void _saveSelection() {
    // Map'ten Listeye geri donustur (Flatten)
    List<ServiceResponse> result = [];
    _counts.forEach((id, count) {
      final service = _serviceMap[id];
      if (service != null) {
        for (int i = 0; i < count; i++) {
          result.add(service);
        }
      }
    });
    widget.onSelectionChanged(result);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.routes_services.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _saveSelection,
                  child: Text(LocaleKeys.buttons_save.tr()),
                ),
              ],
            ),
          ),

          // Search Bar eklenebilir
          Expanded(
            child: BlocBuilder<GetServiceItemCubit, GetServiceItemState>(
              builder: (context, state) {
                if (state is GetServiceItemLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is GetServiceItemLoaded) {
                  final list = state.serviceItems;
                  return ListView.separated(
                    itemCount: list.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final count = _counts[item.id] ?? 0;
                      final isSelected = count > 0;

                      // ServiceCard widgetinizi tekrar kullaniyoruz
                      return ServiceCard(
                        service: item,
                        isSelected: isSelected,
                        count: count,
                        onTap: () =>
                            _updateCount(item, 1), // Tiklayinca 1 arttir
                        onIncrement: () => _updateCount(item, 1),
                        onDecrement: () => _updateCount(item, -1),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
