import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_failed_widget.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import 'categories_row_widget.dart';
import 'home_product_card.dart';

class HomeContentWidget extends StatelessWidget {
  const HomeContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return CustomFailedWidget(
            message: state.message,
            onRetry: () => context.read<HomeCubit>().loadData(),
          );
        }
        if (state is HomeLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoriesRow(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onSelectCategory: (id) =>
                    context.read<HomeCubit>().selectCategory(id),
              ),
              Divider(
                color: AppColors.greyA4ACAD,
                thickness: 1,
                height: 20,
                indent: 16,
                endIndent: 16,
              ),
              Expanded(
                child: state.products.isEmpty
                    ? Center(
                        child: Text(
                          'home.no_products'.tr(),
                          style: AppFonts.styleRegular14.copyWith(
                            color: AppColors.greyA4ACAD,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          const horizontalPadding = 16.0;
                          const spacing = 8.0;
                          // Max width per card; more columns on wider screens so cards stay within this
                          const maxCardWidth = 280.0;
                          final width = constraints.maxWidth;
                          final crossAxisCount =
                              ((width - horizontalPadding + spacing) /
                                      (maxCardWidth + spacing))
                                  .ceil()
                                  .clamp(2, 8);
                          final itemWidth =
                              (width -
                                  horizontalPadding -
                                  (crossAxisCount - 1) * spacing) /
                              crossAxisCount;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (var i = 0; i < state.products.length; i++)
                                  SizedBox(
                                    width: itemWidth,
                                    child: HomeProductCard(
                                      product: state.products[i],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
