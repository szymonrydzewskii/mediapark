import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/widgets/adaptive_asset_image.dart';
import 'package:mediapark/style/app_style.dart';
import '../models/budzet_obywatelski_details.dart';
import '../services/budzet_obywatelski_details_service.dart';

class BudzetObywatelskiDetailsScreen extends StatelessWidget {
  final int projectId;

  const BudzetObywatelskiDetailsScreen({super.key, required this.projectId});

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primaryLight,
        centerTitle: true,
      ),
      body: FutureBuilder<BudzetObywatelskiDetails>(
        future: fetchProjektDetails(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Brak danych'));
          } else {
            final details = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (details.mainPhotoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: AdaptiveAssetImage(
                            basePath: 'assets/icons/city',
                            height: 200.h,
                            width: 200.w,
                          ),
                        ),
                      ),
                    SizedBox(height: 8.h),
                    if (details.projectStatusValue != null)
                      _buildRow("Status:", details.projectStatusValue!),
                    if (details.typeValue != null)
                      _buildRow("Rodzaj:", details.typeValue!),
                    if (details.projectEstimatedCostValue != null)
                      _buildRow(
                        "Koszt:",
                        details.projectEstimatedCostValue!.replaceAll(
                          '&nbsp;',
                          '.',
                        ),
                      ),
                    if (details.projectEditionValue != null)
                      _buildRow("Edycja:", details.projectEditionValue!),
                    SizedBox(height: 12.h),
                    if (details.longDescValue != null)
                      Text(
                        _stripHtml(details.longDescValue!),
                        style: TextStyle(fontSize: 14.sp),
                        textAlign: TextAlign.justify,
                      ),
                    SizedBox(height: 12.h),
                    if (details.additionalDataValue != null)
                      if (details.additionalDataValue is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (details.additionalDataValue as List).map<
                                Widget
                              >((item) {
                                final label = item['label'] ?? '';
                                final value = item['value'] ?? '';
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '${_stripHtml(label.toString())}: ${_stripHtml(value.toString())}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                        )
                      else if (details.additionalDataValue is Map)
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Text(
                            details.additionalDataValue.toString(),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Text(
                            _stripHtml(details.additionalDataValue.toString()),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
