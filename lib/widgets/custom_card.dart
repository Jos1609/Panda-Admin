// lib/widgets/custom_card.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomCard extends StatelessWidget {
  /// El contenido del card
  final Widget child;

  /// Padding interno del card
  final EdgeInsetsGeometry? padding;

  /// Color de fondo del card
  final Color? backgroundColor;

  /// Elevación del card
  final double? elevation;

  /// Radio del borde del card
  final double? borderRadius;

  /// Color del borde del card
  final Color? borderColor;

  /// Ancho del borde del card
  final double? borderWidth;

  /// Margen externo del card
  final EdgeInsetsGeometry? margin;

  /// Función al presionar el card
  final VoidCallback? onTap;

  /// Si el card debe mostrar un efecto de hover
  final bool enableHover;

  /// Si el card debe mostrar un efecto de sombra
  final bool enableShadow;

  /// Widget para mostrar en la esquina superior derecha
  final Widget? headerAction;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.margin,
    this.onTap,
    this.enableHover = true,
    this.enableShadow = true,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spacingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppTheme.borderRadiusMedium,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppTheme.borderRadiusMedium,
              ),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor!,
                      width: borderWidth ?? 1.0,
                    )
                  : null,
              boxShadow: enableShadow
                  ? [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: elevation ?? AppTheme.elevationSmall,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppTheme.borderRadiusMedium,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
                    child: child,
                  ),
                  if (headerAction != null)
                    Positioned(
                      top: AppTheme.spacingSmall,
                      right: AppTheme.spacingSmall,
                      child: headerAction!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Variante del CustomCard para mostrar información de estadísticas
class CustomStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CustomStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Variante del CustomCard para mostrar información con títulos
class CustomTitleCard extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool collapsible;
  final bool initiallyExpanded;

  const CustomTitleCard({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.collapsible = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (collapsible) {
      return CustomCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            initiallyExpanded: initiallyExpanded,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actions != null) ...actions!,
                const Icon(Icons.expand_more),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: child,
              ),
            ],
          ),
        ),
      );
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          child,
        ],
      ),
    );
  }
}