import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapark/style/app_style.dart';
import 'package:mediapark/widgets/illustration_empty_state.dart';

/// Wspólny AppBar z back buttonem SVG
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      foregroundColor: Colors.black,
      leading: Transform.translate(
        offset: Offset(8.w, 0),
        child: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_button.svg',
            width: 40.w,
            height: 40.w,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

/// Wspólny tytuł ekranu
class ScreenTitle extends StatelessWidget {
  final String title;

  const ScreenTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Model dla kategorii w chipach
class ChipCategory {
  final String label;
  final dynamic value; // int?, String?, null

  const ChipCategory({required this.label, this.value});
}

/// Pasek z chipami do filtrowania
class CategoryChipBar extends StatelessWidget {
  final List<ChipCategory> categories;
  final dynamic selectedValue;
  final ValueChanged<dynamic> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children:
            categories.map((cat) {
              final isSelected = selectedValue == cat.value;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    cat.label,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primaryMedium,
                  onSelected: (_) => onSelected(cat.value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                    side: BorderSide(
                      color: AppColors.primaryMedium,
                      width: 2.w,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Bazowa karta z możliwością customizacji contentu
class BaseListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const BaseListCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(25.r),
      child: Card(
        color: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Padding(padding: padding ?? EdgeInsets.all(16.w), child: child),
      ),
    );
  }
}

/// Tag z kategorią
class CategoryTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const CategoryTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryMedium,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black,
        ),
      ),
    );
  }
}

/// Przycisk akcji w karcie
class CardActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const CardActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.black : AppColors.primaryLight,
        foregroundColor: isPrimary ? Colors.white : Colors.black,
        elevation: 0,
        side: isPrimary ? null : const BorderSide(color: Color(0xFFACD2DD)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 42.w, vertical: 20.h),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

/// Layout ekranu z listą i bez zdjęcia parku w przypadku braku
class ListScreenLayoutWithoutPhoto extends StatelessWidget {
  final String title;
  final Widget categoryBar;
  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final Widget listContent;

  const ListScreenLayoutWithoutPhoto({
    super.key,
    required this.title,
    required this.categoryBar,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.listContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CommonAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          ScreenTitle(title),
          SizedBox(height: 12.h),
          categoryBar,
          SizedBox(height: 12.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return listContent;
  }
}

/// Layout ekranu z listą i ze zdjeciem w przypadku braku
class ListScreenLayoutWithPhoto extends StatelessWidget {
  final String title;
  final Widget categoryBar;
  final bool isLoading;
  final bool isEmpty;
  final String mainEmptyMessage;
  final String secondEmptyMessage;
  final Widget listContent;

  const ListScreenLayoutWithPhoto({
    super.key,
    required this.title,
    required this.categoryBar,
    required this.isLoading,
    required this.isEmpty,
    required this.mainEmptyMessage,
    required this.secondEmptyMessage,
    required this.listContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CommonAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          ScreenTitle(title),
          SizedBox(height: 12.h),
          categoryBar,
          SizedBox(height: 12.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isEmpty) {
      return IllustrationEmptyState(
        mainText: mainEmptyMessage,
        secondaryText: secondEmptyMessage,
      );
    }
    return listContent;
  }
}
