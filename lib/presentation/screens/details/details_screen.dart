import 'dart:io'; // 用于 File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // 引入 intl
import 'package:fl_chart/fl_chart.dart'; // !! 引入 fl_chart !!
import 'dart:math'; // For min/max calculation

import '../../../data/local/database/app_database.dart'; // 引入数据库类
// 确保你的枚举文件路径正确
import '../../../models/enum.dart';
import '../../../providers/object_providers.dart'; // 引入 Providers
import '../../widgets/log_list_item.dart'; // 引入日志列表项 Widget
import '../../widgets/add_log_dialog.dart'; // !! 引入 AddLogDialog !!

class DetailsScreen extends ConsumerWidget {
  final int objectId;
  final ObjectType objectType;

  const DetailsScreen({
    super.key,
    required this.objectId,
    required this.objectType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String titlePrefix = objectType == ObjectType.plant ? '植物' : '宠物';
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    final detailsAsyncValue =
        objectType == ObjectType.plant
            ? ref.watch(plantDetailsProvider(objectId))
            : ref.watch(petDetailsProvider(objectId));

    final logAsyncValue =
        objectType == ObjectType.plant
            ? ref.watch(plantLogStreamProvider(objectId))
            : ref.watch(petLogStreamProvider(objectId));

    return Scaffold(
      body: detailsAsyncValue.when(
        data: (objectData) {
          if (objectData == null) {
            return const Center(child: Text('对象不存在或已被删除'));
          }

          String name = '';
          String? nickname;
          String? photoPath;
          Widget specificDetails;
          Widget? statisticsSection;

          if (objectType == ObjectType.plant && objectData is Plant) {
            name = objectData.name;
            nickname = objectData.nickname;
            photoPath = objectData.photoPath;
            specificDetails = _buildPlantSpecificDetails(
              context,
              objectData,
              dateFormatter,
            );
          } else if (objectType == ObjectType.pet && objectData is Pet) {
            name = objectData.name;
            nickname = objectData.nickname;
            photoPath = objectData.photoPath;
            specificDetails = _buildPetSpecificDetails(
              context,
              objectData,
              dateFormatter,
            );
            statisticsSection = _buildPetWeightChart(context, ref, objectId);
          } else {
            return const Center(child: Text('数据类型错误'));
          }

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  background:
                      photoPath != null && File(photoPath).existsSync()
                          ? Image.file(
                            File(photoPath),
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.darken,
                            color: Colors.black.withOpacity(0.3),
                          )
                          : Container(
                            color: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              objectType == ObjectType.plant
                                  ? Icons.local_florist
                                  : Icons.pets,
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                    onPressed: () {
                      if (objectType == ObjectType.plant) {
                        context.goNamed(
                          'editPlant',
                          pathParameters: {'id': objectId.toString()},
                        );
                      } else {
                        context.goNamed(
                          'editPet',
                          pathParameters: {'id': objectId.toString()},
                        );
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nickname != null && nickname.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            nickname,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      specificDetails,
                      const Divider(height: 32),

                      if (statisticsSection != null) ...[
                        Text(
                          '成长曲线',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        statisticsSection,
                        const Divider(height: 32),
                      ],

                      Text(
                        '日志记录',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              logAsyncValue.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('还没有日志记录')),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final log = logs[index];
                      return LogListItem(logEntry: log);
                    }, childCount: logs.length),
                  );
                },
                loading:
                    () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                error:
                    (error, stack) => SliverToBoxAdapter(
                      child: Center(child: Text('加载日志失败: $error')),
                    ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('加载详情失败: $error'))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLogDialog(context, ref, objectId, objectType);
        },
        tooltip: '添加日志',
        child: const Icon(Icons.note_add),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPlantSpecificDetails(
    BuildContext context,
    Plant plant,
    DateFormat formatter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plant.species != null && plant.species!.isNotEmpty)
          _buildInfoRow(context, Icons.eco_outlined, '品种', plant.species!),
        if (plant.acquisitionDate != null)
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            '获取日期',
            formatter.format(plant.acquisitionDate!),
          ),
        if (plant.room != null && plant.room!.isNotEmpty)
          _buildInfoRow(context, Icons.location_on_outlined, '位置', plant.room!),
        _buildInfoRow(
          context,
          Icons.access_time,
          '添加于',
          formatter.format(plant.creationDate),
        ),
      ],
    );
  }

  Widget _buildPetSpecificDetails(
    BuildContext context,
    Pet pet,
    DateFormat formatter,
  ) {
    String genderText;
    switch (pet.gender) {
      case Gender.male:
        genderText = '雄性';
        break;
      case Gender.female:
        genderText = '雌性';
        break;
      default:
        genderText = '未知';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pet.species != null && pet.species!.isNotEmpty)
          _buildInfoRow(context, Icons.category_outlined, '种类', pet.species!),
        if (pet.breed != null && pet.breed!.isNotEmpty)
          _buildInfoRow(context, Icons.pets, '品种', pet.breed!),
        if (pet.birthDate != null)
          _buildInfoRow(
            context,
            Icons.cake_outlined,
            '生日',
            formatter.format(pet.birthDate!),
          ),
        if (pet.gender != null)
          _buildInfoRow(
            context,
            pet.gender == Gender.male
                ? Icons.male
                : (pet.gender == Gender.female
                    ? Icons.female
                    : Icons.question_mark),
            '性别',
            genderText,
          ),
        _buildInfoRow(
          context,
          Icons.access_time,
          '添加于',
          formatter.format(pet.creationDate),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  // !! 构建宠物体重图表 Widget !!
  Widget _buildPetWeightChart(BuildContext context, WidgetRef ref, int petId) {
    final chartDataAsyncValue = ref.watch(petWeightChartDataProvider(petId));
    final theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: chartDataAsyncValue.when(
        data: (spots) {
          if (spots.length < 2) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: const Text(
                '体重记录不足 (需至少2条)，\n无法生成曲线图。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final weights = spots.map((spot) => spot.y).toList();
          final double minY =
              weights.isEmpty ? 0.0 : weights.reduce(min).toDouble() * 0.9;
          final double maxY =
              weights.isEmpty ? 10.0 : weights.reduce(max).toDouble() * 1.1;

          final times = spots.map((spot) => spot.x).toList();
          final double minX =
              times.isEmpty
                  ? DateTime.now().millisecondsSinceEpoch.toDouble()
                  : times.reduce(min).toDouble();
          final double maxX =
              times.isEmpty
                  ? DateTime.now().millisecondsSinceEpoch.toDouble() + 1
                  : times.reduce(max).toDouble();
          final double rangeX = (maxX - minX == 0) ? 1.0 : (maxX - minX);

          return Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            // !! 修正点: 移除 LineChart 的动画参数 !!
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                minX: minX,
                maxX: maxX,
                // 动画参数不在 LineChartData 中
                // swapAnimationDuration: const Duration(milliseconds: 250),
                // swapAnimationCurve: Curves.linear,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval:
                      (maxY - minY) / 4 > 0 ? (maxY - minY) / 4 : 1,
                  verticalInterval: rangeX / 4 > 0 ? rangeX / 4 : null,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: rangeX / 4 > 0 ? rangeX / 4 : null,
                      getTitlesWidget: (value, meta) {
                        final dateTime = DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(
                            DateFormat('MM/dd').format(dateTime),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    // 使用 gradient 替代单一 color，效果更好看
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ], // 使用主题色渐变
                    ),
                    // color: theme.colorScheme.primary, // 可以注释掉或移除
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        // 填充区域也用渐变
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.secondary.withOpacity(0.0), // 底部透明
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      // color: theme.colorScheme.primary.withOpacity(0.2), // 注释掉或移除
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.secondaryContainer
                        .withOpacity(0.9), // 试试 Container 颜色
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final textStyle = TextStyle(
                          color:
                              theme
                                  .colorScheme
                                  .onSecondaryContainer, // 使用 onContainer 颜色
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        final dateTime = DateTime.fromMillisecondsSinceEpoch(
                          touchedSpot.x.toInt(),
                        );
                        final dateStr = DateFormat(
                          'yyyy-MM-dd',
                        ).format(dateTime);
                        final weightStr = touchedSpot.y.toStringAsFixed(1);
                        return LineTooltipItem(
                          '$dateStr\n$weightStr kg',
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
              // !! 修正点: 移除 LineChart 的动画参数 !!
              // swapAnimationDuration: const Duration(milliseconds: 250),
              // swapAnimationCurve: Curves.linear,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('Error loading chart data: $error\n$stack');
          return Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: const Text(
              '无法加载体重数据。\n请检查体重日志格式是否正确。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }

  void _showAddLogDialog(
    BuildContext context,
    WidgetRef ref,
    int objectId,
    ObjectType objectType,
  ) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AddLogDialog(objectId: objectId, objectType: objectType);
      },
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('日志记录已添加'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
