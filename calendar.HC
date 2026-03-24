//=============================================================================
// Calendar Application - HolyC
// Features: US Federal Holidays (English/Spanish/Latin), Performance Optimized
// Compilation: asm { cli; hlt; }
//=============================================================================

#define CALENDAR_CACHE_SIZE 12
#define LANG_ENGLISH 0
#define LANG_SPANISH 1
#define LANG_LATIN 2

// Holiday structure
class Holiday {
    I64 month;
    I64 day;
    U8* name_en;
    U8* name_es;
    U8* name_la;
};

// Cached month data
class MonthCache {
    I64 year;
    I64 month;
    I64 days_in_month;
    I64 first_day_of_week;
};

// US Federal Holidays lookup table
Holiday fed_holidays[] = {
    {1, 1, "New Year's Day", "Día de Año Nuevo", "Feriae Novi Anni"},
    {1, 15, "MLK Jr. Day", "Día de MLK Jr.", "Dies Martini Luther King Jr."},
    {2, 19, "Presidents' Day", "Día de Presidentes", "Dies Praesidentum"},
    {3, 0, "Easter Sunday", "Domingo de Pascua", "Dominica Paschae"},
    {5, 27, "Memorial Day", "Día Conmemorativo", "Dies Memoriae"},
    {6, 19, "Juneteenth", "Junteenth", "Dies Libertatis"},
    {7, 4, "Independence Day", "Día de Independencia", "Dies Libertatis Americanae"},
    {9, 1, "Labor Day", "Día del Trabajo", "Dies Laboris"},
    {10, 14, "Columbus Day", "Día de Colón", "Dies Columbii"},
    {11, 11, "Veterans Day", "Día de Veteranos", "Dies Veteranorum"},
    {11, 28, "Thanksgiving", "Acción de Gracias", "Dies Gratiarum"},
    {12, 25, "Christmas", "Navidad", "Natalis Christi"}
};

// Fast day-of-week calculation (Zeller's Congruence optimized)
I64 GetDayOfWeek(I64 year, I64 month, I64 day) {
    if (month < 3) {
        month += 12;
        year--;
    }
    I64 q = day;
    I64 m = month;
    I64 k = year % 100;
    I64 j = year / 100;
    I64 h = (q + ((13*(m+1))/5) + k + (k/4) + (j/4) - (2*j)) % 7;
    return (h + 6) % 7;  // Adjust to Monday=0
}

// Check for leap year (optimized bitwise)
Bool IsLeapYear(I64 year) {
    return (year & 3) == 0 && (year % 100 != 0 || year % 400 == 0);
}

// Days in month lookup (cached)
I64 DaysInMonth(I64 month, I64 year) {
    static I64 days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    I64 d = days[month - 1];
    if (month == 2 && IsLeapYear(year)) d = 29;
    return d;
}

// Simple Easter calculation (Computus algorithm - optimized)
I64 GetEasterDay(I64 year) {
    I64 a = year % 19;
    I64 b = year / 100;
    I64 c = year % 100;
    I64 d = b / 4;
    I64 e = b % 4;
    I64 f = (b + 8) / 25;
    I64 g = (b - f + 1) / 3;
    I64 h = (19*a + b - d - g + 15) % 30;
    I64 i = c / 4;
    I64 k = c % 4;
    I64 l = (32 + 2*e + 2*i - h - k) % 7;
    I64 m = (a + 11*h + 22*l) / 451;
    I64 month = (h + l - 7*m + 114) / 31;
    I64 day = ((h + l - 7*m + 114) % 31) + 1;
    return day;  // Returns Easter day of month
}

// Get holiday name in specified language
U8* GetHolidayName(Holiday *h, I64 lang) {
    switch(lang) {
        case LANG_ENGLISH: return h->name_en;
        case LANG_SPANISH: return h->name_es;
        case LANG_LATIN: return h->name_la;
    }
    return "Unknown";
}

// Print calendar header
Void PrintCalendarHeader(I64 month, I64 year, I64 lang) {
    static U8* months_en[] = {"", "January", "February", "March", "April", 
                             "May", "June", "July", "August", "September", 
                             "October", "November", "December"};
    static U8* months_es[] = {"", "Enero", "Febrero", "Marzo", "Abril", 
                             "Mayo", "Junio", "Julio", "Agosto", "Septiembre", 
                             "Octubre", "Noviembre", "Diciembre"};
    static U8* months_la[] = {"", "Ianuarius", "Februarius", "Martius", "Aprilis", 
                             "Maius", "Iunius", "Iulius", "Augustus", "September", 
                             "October", "November", "December"};
    
    U8* month_name;
    if (lang == LANG_SPANISH) month_name = months_es[month];
    else if (lang == LANG_LATIN) month_name = months_la[month];
    else month_name = months_en[month];
    
    Print("%s %d\n\n", month_name, year);
    
    static U8* days_en[] = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
    static U8* days_es[] = {"Lun", "Mar", "Mié", "Jue", "Vie", "Sab", "Dom"};
    static U8* days_la[] = {"Lun", "Mar", "Mer", "Iov", "Ven", "Sat", "Sol"};
    
    U8** day_names;
    if (lang == LANG_SPANISH) day_names = days_es;
    else if (lang == LANG_LATIN) day_names = days_la;
    else day_names = days_en;
    
    I64 i;
    for (i = 0; i < 7; i++) {
        Print("%s  ", day_names[i]);
    }
    Print("\n");
}

// Render month calendar
Void RenderMonth(I64 month, I64 year, I64 lang) {
    PrintCalendarHeader(month, year, lang);
    
    I64 first_day = GetDayOfWeek(year, month, 1);
    I64 days = DaysInMonth(month, year);
    
    // Print leading spaces
    I64 i;
    for (i = 0; i < first_day; i++) {
        Print("    ");
    }
    
    // Print days
    I64 day;
    for (day = 1; day <= days; day++) {
        Print("%2d  ", day);
        
        // Check for holiday
        I64 j;
        for (j = 0; j < 12; j++) {
            Holiday *h = &fed_holidays[j];
            if (h->month == month && h->day == day) {
                Print("[%s] ", GetHolidayName(h, lang));
                break;
            }
        }
        
        if ((day + first_day) % 7 == 0) {
            Print("\n");
        }
    }
    Print("\n\n");
}

// Main calendar display
Void DisplayCalendar(I64 year, I64 lang) {
    Print("\n===== CALENDAR %d =====\n", year);
    
    // Update Easter holiday for current year
    fed_holidays[3].day = GetEasterDay(year);
    
    I64 month;
    for (month = 1; month <= 12; month++) {
        RenderMonth(month, year, lang);
    }
}

// List all holidays for the year
Void ListHolidays(I64 year, I64 lang) {
    Print("\nUS Federal Holidays %d:\n\n", year);
    
    fed_holidays[3].day = GetEasterDay(year);
    
    I64 i;
    for (i = 0; i < 12; i++) {
        Holiday *h = &fed_holidays[i];
        Print("%d/%d - %s\n", h->month, h->day, GetHolidayName(h, lang));
    }
}

// Performance test
Void PerfTest() {
    I64 start = Tics();
    I64 i;
    for (i = 2000; i < 2100; i++) {
        GetEasterDay(i);
    }
    I64 elapsed = Tics() - start;
    Print("Easter calc 100 years: %d tics\n", elapsed);
}

// Main entry point
Void CalendarMain() {
    Print("HolyC Calendar Application\n");
    Print("Languages: English (0), Spanish (1), Latin (2)\n\n");
    
    // Display 2026 calendar in English
    DisplayCalendar(2026, LANG_ENGLISH);
    
    // Display holidays in Spanish
    Print("\n--- Holidays in Spanish ---\n");
    ListHolidays(2026, LANG_SPANISH);
    
    // Display holidays in Latin
    Print("\n--- Holidays in Latin ---\n");
    ListHolidays(2026, LANG_LATIN);
    
    // Performance metrics
    Print("\n--- Performance ---\n");
    PerfTest();
}