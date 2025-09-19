import 'package:flutter/material.dart';
import '../models/samorzad.dart';
import 'adaptive_asset_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/style/app_style.dart';

class SamorzadListItem extends StatelessWidget {
  final Samorzad samorzad;
  final bool isSelected;
  final VoidCallback onTap;

  const SamorzadListItem({
    super.key,
    required this.samorzad,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40.w,
            height: 40.h,
            child: AdaptiveNetworkImage(
              url: samorzad.herb,
              width: 40.w,
              height: 40.h,
            ),
          ),
          title: Text(
            samorzad.nazwa,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check,
                  color: Colors.green,
                )
              : null,
        ),
      ),
    );
  }
}
