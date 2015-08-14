#ifndef   __ANSISCRN_H
#define   __ANSISCRN_H

#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif


#ifndef _Windows
#ifdef __MSDOS__
#ifndef _CONSOLE
#define _CONSOLE
#endif
#endif
#ifdef _WIN32
#ifndef _CONSOLE
#define _CONSOLE
#endif
#endif
#endif


#ifndef _Windows
int WaitKey(void);

#ifdef _CONSOLE

int IsAnsi(void);

#define   ESC                  27
#define   ANSI_cup(a,b)        printf("%c[%d;%dH",ESC,a,b)
#define   ANSI_up(a)           printf("%c[%dA",ESC,a)
#define   ANSI_down(a)         printf("%c[%dB",ESC,a)
#define   ANSI_right(a)        printf("%c[%dC",ESC,a)
#define   ANSI_left(a)         printf("%c[%dD",ESC,a)
#define   ANSI_locate(a,b)     printf("%c[%d;%df",ESC,a,b)
#define   ANSI_savecurs()      printf("%c[S",ESC)
#define   ANSI_restcurs()      printf("%c[U",ESC)
#define   ANSI_cls()           printf("%c[2J",ESC)
#define   ANSI_cleol()         printf("%c[K",ESC)
#define   ANSI_margins(a,b)    printf("%c[%d;%dr",ESC,a,b)

static char *_atrb_plt[] = {
   "0","1","4","5","7","8"
   };
static char *_fg_plt[] = {
   "0;30","0;31","0;32","0;33",
   "0;34","0;35","0;36","0;37",
   "1;30","1;31","1;32","1;33",
   "1;34","1;35","1;36","1;37"
   };
static char *_bg_plt[] = {
   "40","41","42","43",
   "44","45","46","47"
    };
/* attributes for ANSI_attrib() */
#define   NORMAL         0
#define   BOLD           1
#define   USCORE         2
#define   BLINKANSI      3
#define   REVERSE        4
#define   INVIS          5
#define   ANSI_attrib(a)     printf("%c[%sm",ESC,_atrb_plt[a])
/* ANSI_bg_color() and ANSI_fg_color : a is a color Number */
#define   ANSI_fg_color(a)   printf("%c[%sm",ESC,_fg_plt[a] )
#define   ANSI_bg_color(a)   printf("%c[%sm",ESC,_bg_plt[a] )


#ifdef __MSDOS__
/* Definitions SCAN sous DOS */
#define SCAN_NONE          0x0                                        /* 00 */
#define SCAN_ESC           0x1                                        /* 01 */
#define SCAN_1             0x2                                        /* 02 */
#define SCAN_2             0x3                                        /* 03 */
#define SCAN_3             0x4                                        /* 04 */
#define SCAN_4             0x5                                        /* 05 */
#define SCAN_5             0x6                                        /* 06 */
#define SCAN_6             0x7                                        /* 07 */
#define SCAN_7             0x8                                        /* 08 */
#define SCAN_8             0x9                                        /* 09 */
#define SCAN_9             0xA                                        /* 10 */
#define SCAN_0             0xB                                        /* 11 */
#define SCAN_HYPHEN        0xC                                        /* 12 */
#define SCAN_EQUAL         0xD                                        /* 13 */
#define SCAN_BACKSPACE     0xE                                        /* 14 */
#define SCAN_TAB           0xF                                        /* 15 */
#define SCAN_Q             0x10                                       /* 16 */
#define SCAN_W             0x11                                       /* 17 */
#define SCAN_E             0x12                                       /* 18 */
#define SCAN_R             0x13                                       /* 19 */
#define SCAN_T             0x14                                       /* 20 */
#define SCAN_Y             0x15                                       /* 21 */
#define SCAN_U             0x16                                       /* 22 */
#define SCAN_I             0x17                                       /* 23 */
#define SCAN_O             0x18                                       /* 24 */
#define SCAN_P             0x19                                       /* 25 */
#define SCAN_BRACKET_LEFT  0x1A                                       /* 26 */
#define SCAN_BRACKET_RIGHT 0x1B                                       /* 27 */
#define SCAN_ENTER         0x1C                                       /* 28 */
#define SCAN_CTRL          0x1D                                       /* 29 */
#define SCAN_A             0x1E                                       /* 30 */
#define SCAN_S             0x1F                                       /* 31 */
#define SCAN_D             0x20                                       /* 32 */
#define SCAN_F             0x21                                       /* 33 */
#define SCAN_G             0x22                                       /* 34 */
#define SCAN_H             0x23                                       /* 35 */
#define SCAN_J             0x24                                       /* 36 */
#define SCAN_K             0x25                                       /* 37 */
#define SCAN_L             0x26                                       /* 38 */
#define SCAN_SEMICOLON     0x27                                       /* 39 */
#define SCAN_QUOTE         0x28                                       /* 40 */
#define SCAN_BACKQUOTE     0x29                                       /* 41 */
#define SCAN_SHIFT_LEFT    0x2A                                       /* 42 */
#define SCAN_BACKSLASH     0x2B                                       /* 43 */
#define SCAN_Z             0x2C                                       /* 44 */
#define SCAN_X             0x2D                                       /* 45 */
#define SCAN_C             0x2E                                       /* 46 */
#define SCAN_V             0x2F                                       /* 47 */
#define SCAN_B             0x30                                       /* 48 */
#define SCAN_N             0x31                                       /* 49 */
#define SCAN_M             0x32                                       /* 50 */
#define SCAN_COMMA         0x33                                       /* 51 */
#define SCAN_PERIOD        0x34                                       /* 52 */
#define SCAN_SLASH         0x35                                       /* 53 */
#define SCAN_SHIFT_RIGHT   0x36                                       /* 54 */
#define SCAN_GRAYSTAR      0x37                                       /* 55 */
#define SCAN_ALT           0x38                                       /* 56 */
#define SCAN_SPACE         0x39                                       /* 57 */
#define SCAN_CAPSLOCK      0x3A                                       /* 58 */
#define SCAN_F1            0x3B                                       /* 59 */
#define SCAN_F2            0x3C                                       /* 60 */
#define SCAN_F3            0x3D                                       /* 61 */
#define SCAN_F4            0x3E                                       /* 62 */
#define SCAN_F5            0x3F                                       /* 63 */
#define SCAN_F6            0x40                                       /* 64 */
#define SCAN_F7            0x41                                       /* 65 */
#define SCAN_F8            0x42                                       /* 66 */
#define SCAN_F9            0x43                                       /* 67 */
#define SCAN_F10           0x44                                       /* 68 */
#define SCAN_F11           0x57                                       /* 87 */
#define SCAN_F12           0x58                                       /* 88 */
#define SCAN_NUMLOCK       0x45                                       /* 69 */
#define SCAN_SCROLLOCK     0x46                                       /* 70 */
#define SCAN_HOME          0x47                                       /* 71 */
#define SCAN_UP            0x48                                       /* 72 */
#define SCAN_PGUP          0x49                                       /* 73 */
#define SCAN_GRAYMINUS     0x4A                                       /* 74 */
#define SCAN_LEFT          0x4B                                       /* 75 */
#define SCAN_KP5           0x4C                                       /* 76 */
#define SCAN_RIGHT         0x4D                                       /* 77 */
#define SCAN_GRAYPLUS      0x4E                                       /* 78 */
#define SCAN_END           0x4F                                       /* 79 */
#define SCAN_DOWN          0x50                                       /* 80 */
#define SCAN_PGDN          0x51                                       /* 81 */
#define SCAN_INS           0x52                                       /* 82 */
#define SCAN_DEL           0x53                                       /* 83 */
#define SCAN_SYSRQ         0x54                                       /* 84 */
#endif


#endif
#endif


#ifdef __cplusplus
}
#endif

#endif /* Fin __ANSISCRN_H */
