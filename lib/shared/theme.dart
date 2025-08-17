// lib/shared/theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Dark Mode Color Palette - Modern, Professional LIMS Theme
  static const Color primaryColor = Color(0xFF0078D4); // Microsoft Blue
  static const Color accentColor = Color(0xFF005A9E);
  static const Color secondaryColor = Color(0xFF00BCF2); // Cyan accent
  
  // Background Colors
  static const Color backgroundColor = Color(0xFF121212); // True dark background
  static const Color surfaceColor = Color(0xFF1E1E1E); // Cards, containers
  static const Color cardColor = Color(0xFF2D2D30); // Elevated surfaces
  static const Color elevatedSurfaceColor = Color(0xFF333333); // Dialogs, menus
  
  // Border and Divider Colors
  static const Color borderColor = Color(0xFF404040);
  static const Color dividerColor = Color(0xFF2F2F2F);
  static const Color focusBorderColor = Color(0xFF0078D4);
  
  // Text Colors
  static const Color primaryTextColor = Color(0xFFFFFFFF); // Primary text
  static const Color secondaryTextColor = Color(0xFFB3B3B3); // Secondary text
  static const Color tertiaryTextColor = Color(0xFF808080); // Hint text
  static const Color disabledTextColor = Color(0xFF5A5A5A);
  
  // Status Colors - Professional lab colors
  static const Color successColor = Color(0xFF4CAF50); // Green for success
  static const Color warningColor = Color(0xFFFF9800); // Orange for warnings
  static const Color errorColor = Color(0xFFF44336); // Red for errors
  static const Color infoColor = Color(0xFF2196F3); // Blue for info
  
  // Lab-specific Colors
  static const Color chemistryColor = Color(0xFF9C27B0); // Purple for chemistry
  static const Color microbiologyColor = Color(0xFF4CAF50); // Green for micro
  static const Color metalsColor = Color(0xFFFF5722); // Deep orange for metals
  
  // Interactive Colors
  static const Color hoverColor = Color(0xFF404040);
  static const Color pressedColor = Color(0xFF4A4A4A);
  static const Color selectedColor = Color(0xFF0078D4);
  static const Color rippleColor = Color(0xFF404040);
  
  // Glassmorphism Effects
  static const Color glassColor = Color(0x20FFFFFF);
  static const Color glassBorderColor = Color(0x30FFFFFF);
  static const Color glassBackgroundColor = Color(0x0AFFFFFF);

  // Shadow Colors
  static const Color shadowColor = Color(0x40000000);
  static const Color cardShadowColor = Color(0x20000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        onTertiary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: primaryTextColor,
        background: backgroundColor,
        onBackground: primaryTextColor,
        surfaceVariant: cardColor,
        onSurfaceVariant: secondaryTextColor,
        outline: borderColor,
        outlineVariant: dividerColor,
        shadow: shadowColor,
        surfaceTint: primaryColor,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: backgroundColor,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: primaryTextColor,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: backgroundColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: cardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceColor,
        margin: const EdgeInsets.all(8),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: borderColor,
          disabledForegroundColor: disabledTextColor,
          elevation: 2,
          shadowColor: cardShadowColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: disabledTextColor,
          side: const BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: disabledTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(64, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryTextColor,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: disabledTextColor,
          hoverColor: hoverColor,
          focusColor: selectedColor.withOpacity(0.1),
          highlightColor: pressedColor,
          minimumSize: const Size(40, 40),
          iconSize: 20,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: disabledTextColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: tertiaryTextColor),
        labelStyle: const TextStyle(color: secondaryTextColor),
        prefixIconColor: secondaryTextColor,
        suffixIconColor: secondaryTextColor,
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: borderColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return borderColor;
        }),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return borderColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return borderColor.withOpacity(0.3);
        }),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: elevatedSurfaceColor,
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: const TextStyle(color: primaryTextColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 8,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: false,
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        iconColor: secondaryTextColor,
        selectedTileColor: selectedColor,
        selectedColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Data Table Theme
      dataTableTheme: DataTableThemeData(
        columnSpacing: 24,
        horizontalMargin: 16,
        decoration: const BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        headingTextStyle: const TextStyle(
          color: primaryTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        dataTextStyle: const TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        headingRowColor: MaterialStateProperty.all(cardColor),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return selectedColor.withOpacity(0.1);
          }
          if (states.contains(MaterialState.hovered)) {
            return hoverColor.withOpacity(0.5);
          }
          return null;
        }),
      ),
      
      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(elevatedSurfaceColor),
          elevation: MaterialStateProperty.all(8),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: borderColor,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.1),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        // Display styles - for large, prominent text
        displayLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: primaryTextColor,
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        
        // Headline styles - for headers and titles
        headlineLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        
        // Title styles - for section headers
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        
        // Label styles - for buttons and form labels
        labelLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        
        // Body styles - for regular content
        bodyLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryTextColor,
        size: 20,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 20,
      ),
      
      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: elevatedSurfaceColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        textStyle: const TextStyle(
          color: primaryTextColor,
          fontSize: 12,
        ),
        preferBelow: false,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      ),
      
      // Navigation Rail Theme
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceColor,
        selectedIconTheme: IconThemeData(color: primaryColor, size: 24),
        unselectedIconTheme: IconThemeData(color: secondaryTextColor, size: 24),
        selectedLabelTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
        unselectedLabelTextStyle: TextStyle(color: secondaryTextColor),
        groupAlignment: 0.0,
        labelType: NavigationRailLabelType.selected,
        useIndicator: true,
        indicatorColor: selectedColor,
        elevation: 0,
      ),
      
      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: selectedColor,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white, size: 24);
          }
          return const IconThemeData(color: secondaryTextColor, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: primaryColor, fontWeight: FontWeight.w500);
          }
          return const TextStyle(color: secondaryTextColor);
        }),
        height: 80,
        elevation: 0,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: secondaryTextColor,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: elevatedSurfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Expansion Tile Theme
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: surfaceColor,
        collapsedBackgroundColor: surfaceColor,
        textColor: primaryTextColor,
        collapsedTextColor: primaryTextColor,
        iconColor: secondaryTextColor,
        collapsedIconColor: secondaryTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Menu Theme
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: MaterialStateProperty.all(elevatedSurfaceColor),
          elevation: MaterialStateProperty.all(8),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      
      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: elevatedSurfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: primaryTextColor, fontSize: 14),
      ),
      
      // Time Picker Theme
      timePickerTheme: TimePickerThemeData(
        backgroundColor: elevatedSurfaceColor,
        hourMinuteTextColor: primaryTextColor,
        dayPeriodTextColor: primaryTextColor,
        dialHandColor: primaryColor,
        dialBackgroundColor: cardColor,
        dialTextColor: primaryTextColor,
        entryModeIconColor: primaryColor,
        hourMinuteColor: cardColor,
        dayPeriodColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // Date Picker Theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: elevatedSurfaceColor,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        dayForegroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return primaryTextColor;
        }),
        dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        todayForegroundColor: MaterialStateProperty.all(primaryColor),
        todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
        yearForegroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return primaryTextColor;
        }),
        yearBackgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dayShape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        yearShape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
  
  // Helper method to get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
      case 'approved':
        return successColor;
      case 'warning':
      case 'pending':
      case 'in_progress':
        return warningColor;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'inactive':
        return errorColor;
      case 'info':
      case 'draft':
        return infoColor;
      default:
        return secondaryTextColor;
    }
  }
  
  // Helper method to get department color
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'chemistry':
        return chemistryColor;
      case 'microbiology':
        return microbiologyColor;
      case 'metals':
        return metalsColor;
      default:
        return primaryColor;
    }
  }
}