//
//  NJNotebookPaperInfo.m
//  NeoJournal
//
//  Copyright (c) 2014 Neolab. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NJNotebookPaperInfo.h"
#import "NPPaperManager.h"
#import "NJNotebookInfoStore.h"



NotebookInfoType notebookTypeArray[] = {
    {0, 19, 1, 102, 62, 89, 4, 1, 1.2f, 1.0f, "", "", "Note_ID_1_even.png", "Note_ID_1_odd.png"},   // Season Notebook Default Note
//    {1, 102, 62, 88, 4, 6, 1.0f, 1.1f, "", "", "Note_ID_1_even.png", "Note_ID_1_odd.png"},   // Season Notebook Default Note
    {3, 27, 101, 64, 78, 109, 2, 2, 0.0f, 0.0f, "", "", "", ""}, // Neo1 Large
    {3, 27, 102, 64, 65, 92, 2, 2, 0.0f, 0.0f, "", "", "", ""},  // Neo1 Medium
    {3, 27, 103, 160, 41, 57, 2, 2, 0.0f, 0.0f, "", "", "", ""}, // Neo1 Small
    {3, 27, 201, 64, 84, 107, 2, 2, 0.0f, 0.0f, "", "", "", ""}, // SnowCat Large
    {3, 27, 202, 64, 69, 95, 2, 2, 0.0f, 0.0f, "", "", "", ""},  // SnowCat Medium
    {3, 27, 203, 64, 56, 77, 2, 2, 0.0f, 0.0f, "", "", "", ""},   // SnowCat Small
//    {3, 27, 301, 64, 74, 106, 0, 0, 4.8f, 4.8f, "N-note_03_1.png", "N-note_03_2.png", "N-note_03_even.png", "N-note_03_odd.png"}, // Neo Basic 01"
//    {3, 27, 302, 64, 74, 106, 0, 0, 4.8f, 4.8f, "N-note_03_1.png", "N-note_03_2.png", "N-note_03_even.png", "N-note_03_odd.png"}, // Neo Basic 02"
//    {3, 27, 303, 64, 74, 106, 0, 0, 4.8f, 4.8f, "N-note_03_1.png", "N-note_03_2.png", "N-note_03_even.png", "N-note_03_odd.png"}, // Neo Basic 03"
    {3, 27, 301, 64, 74, 106, 0, 0, 4.8f, 4.8f, "", "", "", ""}, // Neo Basic 01"
    {3, 27, 302, 64, 74, 106, 0, 0, 4.8f, 4.8f, "", "", "", ""}, // Neo Basic 02"
    {3, 27, 303, 64, 74, 106, 0, 0, 4.8f, 4.8f, "", "", "", ""}, // Neo Basic 03"
};

//13bits:data(4bit year,4bit month, 5bit date, ex:14 08 28)
//3bits: cmd, (no need => 1bit:dirty bit)
typedef enum {
    None = 0x00,
    Email = 0x01,
    Alarm = 0x02,
    Activity = 0x04
} PageArrayCommandState;

typedef struct{
    int page_id;
    float activeStartX;
    float activeStartY;
    float activeWidth;
    float activeHeight;
    float spanX;
    float spanY;
    int arrayX; //email:action array, alarm|activity: month start array, alarm :startPage
    int arrayY; //email:action array, alarm|activity: month start array, alarm :endPage
    int startDate;
    int endDate;
    int remainedDate;
    int month;
    int year;
    PageArrayCommandState cmd;
} PageInfoType;

PageInfoType s_1_infoType[] = {
    {3, 57.0f, 83.0f, 4.0f, 4.0f, 4.0f, 4.0f, 0, 0, 0, 0, 0, 0, 0,Email},
    {4, 18.0f, 83.0f, 4.0f, 4.0f, 4.0f, 4.0f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType m_2_infoType[] = {
    {1, 73.5f, 105.3f, 2.5f, 2.5f, 2.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_101_infoType[] = {
    {3, 70.0f, 8.4f, 3.0f, 2.0f, 3.0f, 2.0f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_102_infoType[] = {
    {3, 59.0f, 8.5f, 2.0f, 1.5f, 2.0f, 1.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_103_infoType[] = {
    {3, 36.0f, 6.0f, 2.0f, 1.4f, 2.0f, 1.4f, 0, 0, 0, 0, 0, 0, 0,Email},
    {4, 7.7f, 6.0f, 2.0f, 1.4f, 2.0f, 1.4f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_201_infoType[] = {
    {1, 5.0f, 5.0f, 67, 96, 3, 3, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 5.0f, 5.0f, 67, 96, 3, 3, 10, 31, 0, 0, 0, 0, 0,Email},
    {3, 5.0f, 5.0f, 67, 96, 3, 3, 14, 31, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_202_infoType[] = {
    {1, 5.0f, 5.0f, 67, 96, 3, 2, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 5.0f, 5.0f, 67, 96, 3, 2, 0, 0, 0, 0, 0, 0, 0,Email},
    {3, 5.0f, 5.0f, 67, 96, 3, 2, 21, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_203_infoType[] = {
    {1, 5.0f, 5.0f, 67, 96, 3, 2, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 5.0f, 5.0f, 67, 96, 3, 2, 0, 0, 0, 0, 0, 0, 0,Email},
    {3, 5.0f, 5.0f, 67, 96, 3, 2, 21, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_1_infoType[] = {
    {1, 9.8f, 9.8f, 67, 96, 3, 2, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 9.8f, 9.8f, 67, 96, 3, 2, 0, 0, 0, 0, 0, 0, 0,Email},
    {3, 9.8f, 9.8f, 67, 96, 3, 2, 21, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_2_infoType[] = {
    {1, 9.8f, 9.8f, 67, 96, 3, 2, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 9.8f, 9.8f, 67, 96, 3, 2, 0, 0, 0, 0, 0, 0, 0,Email},
    {3, 9.8f, 9.8f, 67, 96, 3, 2, 21, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_3_infoType[] = {
    {1, 9.8f, 9.8f, 67, 96, 3, 2, 1, 1, 0, 0, 0, 0, 0,None},
    {2, 9.8f, 9.8f, 67, 96, 3, 2, 0, 0, 0, 0, 0, 0, 0,Email},
    {3, 9.8f, 9.8f, 67, 96, 3, 2, 21, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_601_infoType[] = {
    //{1, 36.0f, 9.0f, 2.0f, 1.5f, 2.0f, 1.5f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 36.0f, 8.6f, 2.0f, 2.0f, 2.0f, 2.0f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_602_infoType[] = {
    //{1, 36.0f, 9.0f, 2.0f, 1.5f, 2.0f, 1.5f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 36.0f, 8.6f, 2.0f, 2.0f, 2.0f, 2.0f, 0, 0, 0, 0, 0, 0, 0,Email},
};

PageInfoType n_603_infoType[] = {
    {1, 9.5f, 8.5f, 55, 80, 2.5, 2, 21, 0, 0, 0, 0, 0, 0,Email},
    {2, 9.5f, 8.5f, 55, 80, 2.5, 2, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_604_infoType[] = {
    //{1, 70.71f, 10.78f, 2.99f, 2.02f, 2.99f, 2.02f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 70.2f, 10.2f, 3.5f, 2.5f, 3.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_610_infoType[] = {
    //{1, 70.71f, 10.78f, 2.99f, 2.02f, 2.99f, 2.02f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 70.2f, 10.2f, 3.5f, 2.5f, 3.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_611_infoType[] = {
    //{1, 70.71f, 10.78f, 2.99f, 2.02f, 2.99f, 2.02f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 70.2f, 10.2f, 3.5f, 2.5f, 3.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_612_infoType[] = {
    //{1, 70.71f, 10.78f, 2.99f, 2.02f, 2.99f, 2.02f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 70.2f, 10.2f, 3.5f, 2.5f, 3.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_613_infoType[] = {
    //{1, 70.71f, 10.78f, 2.99f, 2.02f, 2.99f, 2.02f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 70.2f, 10.2f, 3.5f, 2.5f, 3.5f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_614_infoType[] = {
    //{1, 85.25f, 11.75, 2.74f, 1.79f, 2.74f, 1.79f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 84.75f, 11.25f, 3.24f, 2.29f, 3.24f, 2.29f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_615_infoType[] = {
    //{1, 56.67f, 10.9f, 2.53f, 1.63f, 2.53f, 1.63f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 56.17f, 10.4f, 3.03f, 2.63f, 3.03f, 2.63f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_616_infoType[] = {
    //{1, 38.27f, 9.62f, 1.94f, 1.17f, 1.94f, 1.17f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 37.77f, 9.12f, 2.44f, 2.17f, 2.44f, 2.17f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_617_infoType[] = {
    //{1, 86.44f, 11.78, 3.08f, 1.87f, 3.08f, 1.87f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 85.94f, 11.28f, 4.08f, 2.87f, 4.08f, 2.87f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_618_infoType[] = {
    //{1, 86.44f, 11.78, 3.08f, 1.87f, 3.08f, 1.87f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 85.94f, 11.28f, 4.08f, 2.87f, 4.08f, 2.87f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_619_infoType[] = {
    //{1, 86.44f, 11.78, 3.08f, 1.87f, 3.08f, 1.87f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 85.94f, 11.28f, 4.08f, 2.87f, 4.08f, 2.87f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_609_infoType[] = {
    //{1, 86.93f, 21.45f, 3.2f, 2.05f, 3.2f, 2.05f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 86.4f, 20.9f, 3.7f, 2.5f, 3.7f, 2.5f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_620_infoType[] = {
    //{1, 52.62f, 19.66f, 2.7f, 1.9f, 2.7f, 1.9f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 52.12f, 19.16f, 3.2f, 2.4f, 3.2f, 2.4f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_625_infoType[] = {
    //{1, 61f, 9.2f, 2.9, 2.2, 2.9, 2.2, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 60.5f, 8.7f, 3.4f, 2.7f, 3.4f, 2.7f, 0, 0, 0, 0, 0, 0, 0,Email},
    //{2, 62.2f, 9.2f, 2.9, 2.2, 2.9, 2.2, 0, 0, 0, 0, 0, 0, 0,Email},
    {2, 61.7f, 8.7f, 3.4f, 2.7f, 3.4f, 2.7f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_114_infoType[] = {
    //{1, 32.75f, 6.28f, 3.1f, 2.4f, 3.1f, 2.4f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 32.25f, 5.78f, 3.6f, 2.9f, 3.6f, 2.9f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_700_infoType[] = {
    //{1, 46.93f, 4.95f, 3.4f, 2.1f, 3.4f, 2.1f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 46.43f, 4.45f, 3.9f, 2.6f, 3.4f, 2.1f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_701_infoType[] = {
    //{1, 50.25f, 8.06f, 2.8f, 1.8f, 3.6f, 2.9f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 49.75f, 7.56f, 3.3f, 2.3f, 3.3f, 2.3f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_702_infoType[] = {
    //{1, 50.25f, 8.06f, 2.8f, 1.8f, 3.6f, 2.9f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 49.75f, 7.56f, 3.3f, 2.3f, 3.3f, 2.3f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_800_infoType[] = {
    //{1, 50.50f, 10.17f, 5.2f, 3.9f, 5.2f, 3.9f, 0, 0, 0, 0, 0, 0, 0,Email},
    {1, 50.0f, 9.67f, 5.7f, 4.4f, 5.7f, 4.4f, 0, 0, 0, 0, 0, 0, 0,Email},
};
PageInfoType n_606_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {14, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 4, 28, 0, 1, 15,Activity},//Jan
    {15, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 31, 0, 1, 15,Activity},
    {18, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 25, 0, 2, 15,Activity},//Feb
    {19, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 5, 28, 0, 2, 15,Activity},
    {22, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 31, 0, 3, 15,Activity},//Mar
    {23, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 5, 28, 0, 3, 15,Activity},
    {26, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 3, 0, 1, 29, 0, 4, 15,Activity},//Apr
    {27, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 2, 30, 0, 4, 15,Activity},
    {30, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 3, 27, 31, 5, 15,Activity},//May
    {31, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 30, 0, 5, 15,Activity},
    {34, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 30, 0, 6, 15,Activity},//June
    {35, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 4, 27, 0, 6, 15,Activity},
    {38, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 3, 0, 1, 29, 0, 7, 15,Activity},//July
    {39, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 2, 31, 0, 7, 15,Activity},
    {42, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 2, 26, 30, 8, 15,Activity},//Aug
    {43, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 29, 0, 8, 15,Activity},
    {46, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 30, 0, 9, 15,Activity},//Sep
    {47, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 3, 26, 0, 9, 15,Activity},
    {50, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 4, 28, 0, 10, 15,Activity},//Oct
    {51, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 31, 0, 10, 15,Activity},
    {54, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 30, 0, 11, 15,Activity},//Nov
    {55, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 5, 28, 0, 11, 15,Activity},
    {58, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 30, 0, 12, 15,Activity},//Dec
    {59, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 3, 31, 0, 12, 15,Activity},
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 62, 122, 1, 31, 0,  1, 15, Alarm},//Jan, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 126,180, 1, 28, 0,  2, 15, Alarm},//Feb, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 190,250, 1, 31, 0,  3, 15, Alarm},//Mar, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 254,312, 1, 30, 0,  4, 15, Alarm},//Apr, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 318,378, 1, 31, 0,  5, 15, Alarm},//May, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 382,440, 1, 30, 0,  6, 15, Alarm},//June, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 446,506, 1, 31, 0,  7, 15, Alarm},//July, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 510,570, 1, 31, 0,  8, 15, Alarm},//Aug, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 574,632, 1, 30, 0,  9, 15, Alarm},//Sep, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 638,698, 1, 31, 0,  10, 15, Alarm},//Oct, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 702,760, 1, 30, 0,  11, 15, Alarm},//Nov, high priority works
    {62,  6.6f, 18.9f, 14.8f, 44.6f, 14.8f, 44.6f, 766,826, 1, 31, 0,  12, 15, Alarm},//Dec, high priority works
    
};

PageInfoType n_607_infoType[] = {
 //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
 //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {14, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 1, 4, 28, 0, 1, 15,Activity},//Jan
    {15, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 0, 0, 1, 31, 0, 1, 15,Activity},
    {18, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 0, 1, 25, 0, 2, 15,Activity},//Feb
    {19, 11.4f, 16.5f, 36.9f, 60.4f, 12.3f, 15.1f, 0, 0, 5, 28, 0, 2, 15,Activity},
    {22, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 0, 1, 31, 0, 3, 15,Activity},//Mar
    {23, 11.4f, 16.5f, 36.9f, 60.4f, 12.3f, 15.1f, 0, 0, 5, 28, 0, 3, 15,Activity},
    {26, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 3, 0, 1, 29, 0, 4, 15,Activity},//Apr
    {27, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 0, 0, 2, 30, 0, 4, 15,Activity},
    {30, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 1, 3, 27, 31, 5, 15,Activity},//May
    {31, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 1, 0, 1, 30, 0, 5, 15,Activity},
    {34, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 1, 0, 1, 30, 0, 6, 15,Activity},//June
    {35, 11.4f, 16.5f, 36.9f, 60.4f, 12.3f, 15.1f, 0, 0, 4, 27, 0, 6, 15,Activity},
    {38, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 3, 0, 1, 29, 0, 7, 15,Activity},//July
    {39, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 0, 0, 2, 31, 0, 7, 15,Activity},
    {42, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 1, 2, 26, 30, 8, 15,Activity},//Aug
    {43, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 2, 0, 1, 29, 0, 8, 15,Activity},
    {46, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 2, 0, 1, 30, 0, 9, 15,Activity},//Sep
    {47, 11.4f, 16.5f, 36.9f, 60.4f, 12.3f, 15.1f, 0, 0, 3, 26, 0, 9, 15,Activity},
    {50, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 1, 4, 28, 0, 10, 15,Activity},//Oct
    {51, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 0, 0, 1, 31, 0, 10, 15,Activity},
    {54, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 0, 0, 1, 30, 0, 11, 15,Activity},//Nov
    {55, 11.4f, 16.5f, 36.9f, 60.4f, 12.3f, 15.1f, 0, 0, 5, 28, 0, 11, 15,Activity},
    {58, 11.8f, 16.5f, 49.2f, 75.5f, 12.3f, 15.1f, 2, 0, 1, 30, 0, 12, 15,Activity},//Dec
    {59, 11.4f, 16.5f, 36.9f, 75.5f, 12.3f, 15.1f, 0, 0, 3, 31, 0, 12, 15,Activity},
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 62, 122, 1, 31, 0,  1, 15, Alarm},//Jan, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 126,180, 1, 28, 0,  2, 15, Alarm},//Feb, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 190,250, 1, 31, 0,  3, 15, Alarm},//Mar, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 254,312, 1, 30, 0,  4, 15, Alarm},//Apr, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 318,378, 1, 31, 0,  5, 15, Alarm},//May, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 382,440, 1, 30, 0,  6, 15, Alarm},//June, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 446,506, 1, 31, 0,  7, 15, Alarm},//July, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 510,570, 1, 31, 0,  8, 15, Alarm},//Aug, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 574,632, 1, 30, 0,  9, 15, Alarm},//Sep, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 638,698, 1, 31, 0,  10, 15, Alarm},//Oct, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 702,760, 1, 30, 0,  11, 15, Alarm},//Nov, high priority works
    {62,  7.9f, 22.0f, 25.6f, 56.5f, 25.6f, 56.5f, 766,826, 1, 31, 0,  12, 15, Alarm},//Dec, high priority works
    
};

PageInfoType n_608_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {16, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 31, 0, 12, 14,Activity},//Dec
    {17, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 4, 27, 0, 12, 14,Activity},
    {18, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 4, 28, 0, 1, 15,Activity},//Jan
    {19, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 31, 0, 1, 15,Activity},
    {20, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 25, 0, 2, 15,Activity},//Feb
    {21, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 5, 28, 0, 2, 15,Activity},
    {22, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 31, 0, 3, 15,Activity},//Mar
    {23, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 5, 28, 0, 3, 15,Activity},
    {24, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 3, 0, 1, 29, 0, 4, 15,Activity},//Apr
    {25, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 2, 30, 0, 4, 15,Activity},
    {26, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 3, 27, 31, 5, 15,Activity},//May
    {27, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 30, 0, 5, 15,Activity},
    {28, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 30, 0, 6, 15,Activity},//June
    {29, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 4, 27, 0, 6, 15,Activity},
    {30, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 3, 0, 1, 29, 0, 7, 15,Activity},//July
    {31, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 2, 31, 0, 7, 15,Activity},
    {32, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 2, 26, 30, 8, 15,Activity},//Aug
    {33, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 29, 0, 8, 15,Activity},
    {34, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 30, 0, 9, 15,Activity},//Sep
    {35, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 3, 26, 0, 9, 15,Activity},
    {36, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 4, 28, 0, 10, 15,Activity},//Oct
    {37, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 31, 0, 10, 15,Activity},
    {38, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 30, 0, 11, 15,Activity},//Nov
    {39, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 5, 28, 0, 11, 15,Activity},
    {40, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 30, 0, 12, 15,Activity},//Dec
    {41, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 3, 31, 0, 12, 15,Activity},
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 42, 72, 1, 31, 0,  1, 15, Alarm},//Jan, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 74,101, 1, 28, 0,  2, 15, Alarm},//Feb, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 106,136, 1, 31, 0,  3, 15, Alarm},//Mar, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 138,167, 1, 30, 0,  4, 15, Alarm},//Apr, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 170,200, 1, 31, 0,  5, 15, Alarm},//May, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 202,231, 1, 30, 0,  6, 15, Alarm},//June, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 234,264, 1, 31, 0,  7, 15, Alarm},//July, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 266,296, 1, 31, 0,  8, 15, Alarm},//Aug, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 298,327, 1, 30, 0,  9, 15, Alarm},//Sep, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 330,360, 1, 31, 0,  10, 15, Alarm},//Oct, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 362,391, 1, 30, 0,  11, 15, Alarm},//Nov, high priority works
    {42,  8.9f, 16.6f, 23.5f, 27.3f, 23.5f, 27.3f, 394,424, 1, 31, 0,  12, 15, Alarm},//Dec, high priority works
    
};

PageInfoType n_621_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {14, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 3, 27, 31, 1, 16,Activity},//Jan
    {15, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 30, 0, 1, 16,Activity},
    {18, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 29, 0, 2, 16,Activity},//Feb
    {19, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 4, 27, 0, 2, 16,Activity},
    {22, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 30, 0, 3, 16,Activity},//Mar
    {23, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 3, 31, 0, 3, 16,Activity},
    {26, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 3, 27, 0, 4, 16,Activity},//Apr
    {27, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 30, 0, 4, 16,Activity},
    {30, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 31, 0, 5, 16,Activity},//May
    {31, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 5, 28, 0, 5, 16,Activity},
    {34, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 3, 0, 1, 29, 0, 6, 16,Activity},//June
    {35, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 2, 30, 0, 6, 16,Activity},
    {38, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 3, 27, 31, 7, 16,Activity},//July
    {39, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 30, 0, 7, 16,Activity},
    {42, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 1, 0, 1, 31, 0, 8, 16,Activity},//Aug
    {43, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 4, 27, 0, 8, 16,Activity},
    {46, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 4, 28, 0, 9, 16,Activity},//Sep
    {47, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 30, 0, 9, 16,Activity},
    {50, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 2, 26, 30, 10, 16,Activity},//Oct
    {51, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 29, 0, 10, 16,Activity},
    {54, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 2, 0, 1, 30, 0, 11, 16,Activity},//Nov
    {55, 9.7f, 17.2f, 22.2f, 47.6f, 7.4f, 11.9f, 0, 0, 3, 26, 0, 11, 16,Activity},
    {58, 6.6f, 17.2f, 29.6f, 59.5f, 7.4f, 11.9f, 0, 1, 4, 28, 0, 12, 16,Activity},//Dec
    {59, 9.7f, 17.2f, 22.2f, 59.5f, 7.4f, 11.9f, 0, 0, 1, 31, 0, 12, 16,Activity},
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 62, 122, 1, 31, 0,  1, 16, Alarm},//Jan, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 126,182, 1, 29, 0,  2, 16, Alarm},//Feb, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 190,250, 1, 31, 0,  3, 16, Alarm},//Mar, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 254,312, 1, 30, 0,  4, 16, Alarm},//Apr, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 318,378, 1, 31, 0,  5, 16, Alarm},//May, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 382,440, 1, 30, 0,  6, 16, Alarm},//June, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 446,506, 1, 31, 0,  7, 16, Alarm},//July, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 510,570, 1, 31, 0,  8, 16, Alarm},//Aug, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 574,632, 1, 30, 0,  9, 16, Alarm},//Sep, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 638,698, 1, 31, 0,  10, 16, Alarm},//Oct, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 702,760, 1, 30, 0,  11, 16, Alarm},//Nov, high priority works
    {62,  20.3f, 18.9f, 14.8f, 55.2f, 14.8f, 55.2f, 766,826, 1, 31, 0,  12, 16, Alarm},//Dec, high priority works
    
};

PageInfoType n_622_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {14, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 3, 27, 31, 1, 16,Activity},//Jan
    {15, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 1, 0, 1, 30, 0, 1, 16,Activity},
    {18, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 1, 0, 1, 29, 0, 2, 16,Activity},//Feb
    {19, 9.9f, 14.8f, 27.6f, 47.6f, 9.2f, 11.9f, 0, 0, 4, 27, 0, 2, 16,Activity},
    {22, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 2, 0, 1, 30, 0, 3, 16,Activity},//Mar
    {23, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 0, 0, 3, 31, 0, 3, 16,Activity},
    {26, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 3, 27, 0, 4, 16,Activity},//Apr
    {27, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 1, 0, 1, 30, 0, 4, 16,Activity},
    {30, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 0, 1, 31, 0, 5, 16,Activity},//May
    {31, 9.9f, 14.8f, 27.6f, 47.6f, 9.2f, 11.9f, 0, 0, 5, 28, 0, 5, 16,Activity},
    {34, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 3, 0, 1, 29, 0, 6, 16,Activity},//June
    {35, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 0, 0, 2, 30, 0, 6, 16,Activity},
    {38, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 3, 27, 31, 7, 16,Activity},//July
    {39, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 1, 0, 1, 30, 0, 7, 16,Activity},
    {42, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 1, 0, 1, 31, 0, 8, 16,Activity},//Aug
    {43, 9.9f, 14.8f, 27.6f, 47.6f, 9.2f, 11.9f, 0, 0, 4, 27, 0, 8, 16,Activity},
    {46, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 4, 28, 0, 9, 16,Activity},//Sep
    {47, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 0, 0, 1, 30, 0, 9, 16,Activity},
    {50, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 2, 26, 30, 10, 16,Activity},//Oct
    {51, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 2, 0, 1, 29, 0, 10, 16,Activity},
    {54, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 2, 0, 1, 30, 0, 11, 16,Activity},//Nov
    {55, 9.9f, 14.8f, 27.6f, 47.6f, 9.2f, 11.9f, 0, 0, 3, 26, 0, 11, 16,Activity},
    {58, 9.2f, 14.8f, 36.8f, 59.5f, 9.2f, 11.9f, 0, 1, 4, 28, 0, 12, 16,Activity},//Dec
    {59, 9.9f, 14.8f, 27.6f, 59.5f, 9.2f, 11.9f, 0, 0, 1, 31, 0, 12, 16,Activity},
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 62, 122, 1, 31, 0,  1, 16, Alarm},//Jan, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 126,182, 1, 29, 0,  2, 16, Alarm},//Feb, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 1, 31, 0,  3, 16, Alarm},//Mar, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 254,312, 1, 30, 0,  4, 16, Alarm},//Apr, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 318,378, 1, 31, 0,  5, 16, Alarm},//May, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 382,440, 1, 30, 0,  6, 16, Alarm},//June, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 446,506, 1, 31, 0,  7, 16, Alarm},//July, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 510,570, 1, 31, 0,  8, 16, Alarm},//Aug, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 574,632, 1, 30, 0,  9, 16, Alarm},//Sep, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 638,698, 1, 31, 0,  10, 16, Alarm},//Oct, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 702,760, 1, 30, 0,  11, 16, Alarm},//Nov, high priority works
    {62,  25.0f, 18.8f, 18.3f, 55.2f, 18.3f, 55.2f, 766,826, 1, 31, 0,  12, 16, Alarm},//Dec, high priority works
    
};

PageInfoType n_623_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {16, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 30, 0, 12, 15,Activity},//Dec
    {17, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 3, 31, 0, 12, 15,Activity},
    {18, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 3, 27, 31, 1, 16,Activity},//Jan
    {19, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 30, 0, 1, 16,Activity},
    {20, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 29, 0, 2, 16,Activity},//Feb
    {21, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 4, 27, 0, 2, 16,Activity},
    {22, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 30, 0, 3, 16,Activity},//Mar
    {23, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 3, 31, 0, 3, 16,Activity},
    {24, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 3, 27, 0, 4, 16,Activity},//Apr
    {25, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 30, 0, 4, 16,Activity},
    {26, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 31, 0, 5, 16,Activity},//May
    {27, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 5, 28, 0, 5, 16,Activity},
    {28, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 3, 0, 1, 29, 0, 6, 16,Activity},//June
    {29, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 2, 30, 0, 6, 16,Activity},
    {30, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 3, 27, 31, 7, 16,Activity},//July
    {31, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 30, 0, 7, 16,Activity},
    {32, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 1, 0, 1, 31, 0, 8, 16,Activity},//Aug
    {33, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 4, 27, 0, 8, 16,Activity},
    {34, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 4, 28, 0, 9, 16,Activity},//Sep
    {35, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 30, 0, 9, 16,Activity},
    {36, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 2, 26, 30, 10, 16,Activity},//Oct
    {37, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 29, 0, 10, 16,Activity},
    {38, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 2, 0, 1, 30, 0, 11, 16,Activity},//Nov
    {39, 7.2f, 12.2f, 28.5f, 36.4f, 9.5f, 9.1f, 0, 0, 3, 26, 0, 11, 16,Activity},
    {40, 9.0f, 12.2f, 38.0f, 45.5f, 9.5f, 9.1f, 0, 1, 4, 28, 0, 12, 16,Activity},//Dec
    {41, 7.2f, 12.2f, 28.5f, 45.5f, 9.5f, 9.1f, 0, 0, 1, 31, 0, 12, 16,Activity},
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 42, 72, 1, 31, 0,  1, 16, Alarm},//Jan, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 74,102, 1, 29, 0,  2, 16, Alarm},//Feb, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 106,136, 1, 31, 0,  3, 16, Alarm},//Mar, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 138,167, 1, 30, 0,  4, 16, Alarm},//Apr, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 170,200, 1, 31, 0,  5, 16, Alarm},//May, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 202,231, 1, 30, 0,  6, 16, Alarm},//June, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 234,264, 1, 31, 0,  7, 16, Alarm},//July, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 266,296, 1, 31, 0,  8, 16, Alarm},//Aug, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 298,327, 1, 30, 0,  9, 16, Alarm},//Sep, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 330,360, 1, 31, 0,  10, 16, Alarm},//Oct, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 362,391, 1, 30, 0,  11, 16, Alarm},//Nov, high priority works
    {42, 31.8f, 16.6f, 14.3f, 27.3f, 14.3f, 27.3f, 394,424, 1, 31, 0,  12, 16, Alarm},//Dec, high priority works
    
};

PageInfoType n_624_infoType[] = {
    //page_id, activeStartX, activeStartY, activeWidth, activeHeight, spanX, spanY,
    //arrayX(start), arrayY(start), startDate, endDate, remainedDate, month, year, cmd
    {16, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 2, 0, 1, 30, 0, 12, 15,Activity},//Dec
    {17, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 0, 0, 3, 31, 0, 12, 15,Activity},
    {18, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 3, 27, 31, 1, 16,Activity},//Jan
    {19, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 1, 0, 1, 30, 0, 1, 16,Activity},
    {20, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 1, 0, 1, 29, 0, 2, 16,Activity},//Feb
    {21, 6.4f, 14.5f, 40.8f, 43.2f, 13.6f, 10.8f, 0, 0, 4, 27, 0, 2, 16,Activity},
    {22, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 2, 0, 1, 30, 0, 3, 16,Activity},//Mar
    {23, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 0, 0, 3, 31, 0, 3, 16,Activity},
    {24, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 3, 27, 0, 4, 16,Activity},//Apr
    {25, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 1, 0, 1, 30, 0, 4, 16,Activity},
    {26, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 0, 1, 31, 0, 5, 16,Activity},//May
    {27, 6.4f, 14.5f, 40.8f, 43.2f, 13.6f, 10.8f, 0, 0, 5, 28, 0, 5, 16,Activity},
    {28, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 3, 0, 1, 29, 0, 6, 16,Activity},//June
    {29, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 0, 0, 2, 30, 0, 6, 16,Activity},
    {30, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 3, 27, 31, 7, 16,Activity},//July
    {31, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 1, 0, 1, 30, 0, 7, 16,Activity},
    {32, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 1, 0, 1, 31, 0, 8, 16,Activity},//Aug
    {33, 6.4f, 14.5f, 40.8f, 43.2f, 13.6f, 10.8f, 0, 0, 4, 27, 0, 8, 16,Activity},
    {34, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 4, 28, 0, 9, 16,Activity},//Sep
    {35, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 0, 0, 1, 30, 0, 9, 16,Activity},
    {36, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 2, 26, 30, 10, 16,Activity},//Oct
    {37, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 2, 0, 1, 29, 0, 10, 16,Activity},
    {38, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 2, 0, 1, 30, 0, 11, 16,Activity},//Nov
    {39, 6.4f, 14.5f, 40.8f, 43.2f, 13.6f, 10.8f, 0, 0, 3, 26, 0, 11, 16,Activity},
    {40, 8.5f, 14.5f, 54.4f, 54.0f, 13.6f, 10.8f, 0, 1, 4, 28, 0, 12, 16,Activity},//Dec
    {41, 6.4f, 14.5f, 40.8f, 54.0f, 13.6f, 10.8f, 0, 0, 1, 31, 0, 12, 16,Activity},
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 42, 72, 1, 31, 0,  1, 16, Alarm},//Jan, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 74,102, 1, 29, 0,  2, 16, Alarm},//Feb, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 106,136, 1, 31, 0,  3, 16, Alarm},//Mar, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 138,167, 1, 30, 0,  4, 16, Alarm},//Apr, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 170,200, 1, 31, 0,  5, 16, Alarm},//May, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 202,231, 1, 30, 0,  6, 16, Alarm},//June, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 234,264, 1, 31, 0,  7, 16, Alarm},//July, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 266,296, 1, 31, 0,  8, 16, Alarm},//Aug, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 298,327, 1, 30, 0,  9, 16, Alarm},//Sep, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 330,360, 1, 31, 0,  10, 16, Alarm},//Oct, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 362,391, 1, 30, 0,  11, 16, Alarm},//Nov, high priority works
    {42, 42.7f, 19.7f, 20.4f, 35.7f, 20.4f, 35.7f, 394,424, 1, 31, 0,  12, 16, Alarm},//Dec, high priority works
    
};

typedef struct {
    UInt32 note_id;
    PageInfoType *pageInfo;
} NotebookPuiInfoType;

NotebookPuiInfoType notebookPuiTypeArray[] = {
    {2, m_2_infoType},   //mscribe
    {601, n_601_infoType}, //pocket note
    {602, n_602_infoType}, //memo note
    {603, n_603_infoType}, //spring note
    {604, n_604_infoType}, //plain note 01
    {606, n_606_infoType}, //franklin planner original CEO
    {607, n_607_infoType}, //franklin planner original classic
    {608, n_608_infoType}, //franklin planner casual
    {609, n_609_infoType}, //idea pad
    {610, n_610_infoType}, //plain note 02
    {611, n_611_infoType}, //plain note 03
    {612, n_612_infoType}, //plain note 04
    {613, n_613_infoType}, //plain note 05
    {614, n_614_infoType}, //N A4
    {615, n_615_infoType}, //professional note
    {616, n_616_infoType}, //professional note mini
    {617, n_617_infoType}, //college note 01
    {618, n_618_infoType}, //college note 02
    {619, n_619_infoType}, //college note 03
    {620, n_620_infoType}, //idea pad mini
    {621, n_621_infoType}, //franklin planner CEO 2016
    {622, n_622_infoType}, //franklin planner CO 2016
    {623, n_623_infoType}, //casual planner 32 2016
    {624, n_624_infoType}, //casual planner 25 2016
    {625, n_625_infoType}, //n blank planner
    {114, n_114_infoType}, //oree note
    {700, n_700_infoType}, //Moleskine Neobook
    {701, n_701_infoType}, //Moleskine Mbook1
    {702, n_702_infoType}, //Moleskine Mbook2
    {800, n_800_infoType}, //KimJungKi Edition
};

@interface NJNotebookPaperInfo()
@property (strong, nonatomic) NSDictionary *notebookInfos;
@property (strong, nonatomic) NSArray *notesSupported;

@end

@implementation NJNotebookPaperInfo
+ (NJNotebookPaperInfo *) sharedInstance
{
    static NJNotebookPaperInfo *shared = nil;
    
    @synchronized(self) {
        if(!shared){
            shared = [[NJNotebookPaperInfo alloc] init];
        }
    }
    
    return shared;
}
- (id) init
{
    self = [super init];

    if(self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"note_paper_info" ofType:@"plist"];
//        _notebookInfos = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

        _noteListLength = -1;

        plistPath = [[NSBundle mainBundle] pathForResource:@"note_support_list" ofType:@"plist"];
        _notesSupported = [[NSArray alloc] initWithContentsOfFile:plistPath];
//jr temp
//        NSMutableArray *tempNoteSupportedFromDB = [[NPPaperManager sharedInstance] notesSupportedFromDB];
//        NSMutableArray *tempNotesSupported = [_notesSupported mutableCopy];
//        [tempNotesSupported addObjectsFromArray:tempNoteSupportedFromDB];
//        _notesSupported = [NSArray arrayWithArray:tempNotesSupported];
        
//NISDK - pui from plist - it is not applied to neo notes
//        plistPath = [[NSBundle mainBundle] pathForResource:@"note_pui_info" ofType:@"plist"];
//        _notesbookPuiInfos = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
//        NSArray *registeredPuiNotebook = [_notesbookPuiInfos allKeys];
//        NSInteger count = [registeredPuiNotebook count];
        
        int infoSize = sizeof(notebookPuiTypeArray)/sizeof(NotebookPuiInfoType);
//NISDK
//        self.notebookPuiInfo = [[NSMutableDictionary alloc] initWithCapacity:(infoSize + count)];
        self.notebookPuiInfo = [[NSMutableDictionary alloc] initWithCapacity:infoSize];
        
        for (int i = 0; i < infoSize; i++) {
            NotebookPuiInfoType info = notebookPuiTypeArray[i];
            NSDictionary *puiInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSValue valueWithPointer:info.pageInfo], @"page_info", nil];
            [self.notebookPuiInfo setObject:puiInfo forKey:[NSNumber numberWithInt:info.note_id]];
        }

//NISDK - pui from plist
//        for (int i = 0; i < count; i++) {
//            NSArray *tempInfo = [_notesbookPuiInfos objectForKey:registeredPuiNotebook[i]];
//            NSInteger count = [tempInfo count];
//            PageInfoType *tempPageInfo = (PageInfoType *)malloc(sizeof(PageInfoType) * count);
//            int index = 0;
//            for (NSDictionary *note in tempInfo) {
//                tempPageInfo[index].page_id = [[note objectForKey:@"pageNumber"] intValue];
//                tempPageInfo[index].activeStartX = [[note objectForKey:@"activeStartX"] floatValue];
//                tempPageInfo[index].activeStartY = [[note objectForKey:@"activeStartY"] floatValue];
//                tempPageInfo[index].activeWidth = [[note objectForKey:@"activeWidth"] floatValue];
//                tempPageInfo[index].activeHeight = [[note objectForKey:@"activeHeight"] floatValue];
//                tempPageInfo[index].spanX = [[note objectForKey:@"activeWidth"] floatValue];
//                tempPageInfo[index].spanY = [[note objectForKey:@"activeHeight"] floatValue];
//                tempPageInfo[index].arrayX = 0;
//                tempPageInfo[index].arrayY = 0;
//                NSString *command = [note objectForKey:@"cmd"];
//                if ([command isEqualToString:@"Email"]) {
//                    tempPageInfo[index].cmd = 0x01;
//                } else if ([command isEqualToString:@"Alarm"]){
//                    tempPageInfo[index].cmd = 0x02;
//                } else if ([command isEqualToString:@"Activity"]){
//                    tempPageInfo[index].cmd = 0x04;
//                }
//                
//                index ++;
//            }
//            
//            NSDictionary *puiInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSValue valueWithPointer:tempPageInfo], @"page_info", nil];
//            [self.notebookPuiInfo setObject:puiInfo forKey:[NSNumber numberWithInteger: [registeredPuiNotebook[i] integerValue]]];
//            
//        }
        self.tempNotebooks = [NSMutableArray array];
    }
    
    return self;
}
//not used
- (int)noteListLength
{
    if (_noteListLength == -1) {
        _noteListLength = (int)[_notebookInfos count];
    }
    return _noteListLength;
}
- (BOOL) hasInfoForNotebookId:(int)notebookId
{
    for (NSDictionary *noteDict in _notesSupported) {
        if ([(NSArray *)[noteDict objectForKey:@"noteIds"] indexOfObject:[NSNumber numberWithInt:notebookId]] != NSNotFound) {
            return YES;
        }
    }
    NSUInteger section, owner;
    [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
    NSString *keyNameDB = [NPPaperManager keyNameForNotebookId:notebookId section:section owner:owner];
    
    if(![[NPPaperManager sharedInstance] hasPaperInfoForKeyName:keyNameDB]){
        if (![self.tempNotebooks containsObject:keyNameDB]) {
            [self.tempNotebooks addObject:keyNameDB];
        }

         return NO;
    } else
        return YES;
}

- (BOOL) hasInfoForNotebookIdFromPlist:(int)notebookId
{
    for (NSDictionary *noteDict in _notesSupported) {
        if ([(NSArray *)[noteDict objectForKey:@"noteIds"] indexOfObject:[NSNumber numberWithInt:notebookId]] != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) hasInfoForSectionId:(int)sectionId OwnerId:(int)ownerId
{
    for (NSDictionary *noteDict in _notesSupported) {
        if (([(NSNumber *)[noteDict objectForKey:@"section"] isEqualToNumber:[NSNumber numberWithInt:sectionId]])
            && ([(NSNumber *)[noteDict objectForKey:@"owner"] isEqualToNumber:[NSNumber numberWithInt:ownerId]])) {
            return YES;
        }
    }

    return NO;
}

- (UInt32) sectionIdAndOwnerIdFromNotebookID:(UInt32)notebookId
{
    UInt32 ownerId;
    unsigned char sectionId;
    UInt32 sectionOwnerId = 0;
    
    BOOL notebookExisted = [self hasInfoForNotebookId:notebookId];
    
    if (notebookExisted) {
        for (NSDictionary *noteDict in _notesSupported) {
            if ([(NSArray *)[noteDict objectForKey:@"noteIds"] indexOfObject:[NSNumber numberWithInt:notebookId]] != NSNotFound){
                sectionId = [(NSNumber *)[noteDict objectForKey:@"section"] unsignedCharValue];
                ownerId = (UInt32)[(NSNumber *)[noteDict objectForKey:@"owner"] unsignedIntegerValue];
                sectionOwnerId = (sectionId << 24) | ownerId;
            }
        }
        if (sectionOwnerId == 0) {
            NSUInteger section, owner;
            [NPPaperManager section:&section owner:&owner fromNotebookId:notebookId];
            sectionId = (unsigned char)section;
            ownerId = (UInt32)owner;
            sectionOwnerId = (sectionId << 24) | ownerId;
        }
    } else {
        return 0;
    }
                           
    return sectionOwnerId;
}

- (BOOL) getPaperDotcodeRangeForNotebook:(int)notebookId PageNumber:(int)pageNumber Xmax:(float *)x Ymax:(float *)y
{
    // Temporary code. We are getting section id and owner id from a pen.
    // But it's not implemented to use the ids. Have a look at note_paper_info.plist
    unsigned int sectionId = 0;
    unsigned int ownerId = 0;
    if (sectionId == 0 && ownerId == 0) {
        if (notebookId == 1) {
            sectionId = 0;
            ownerId = 19;
        }
        else {
            sectionId = 3;
            ownerId = 27;
        }
    }
    
    UInt32 sectionOwnerID = [self sectionIdAndOwnerIdFromNotebookID:notebookId];
    
    if(sectionOwnerID != 0){
        sectionId = (sectionOwnerID >> 24) & 0xFF;
        ownerId = sectionOwnerID & 0x00FFFFFF;
    }
    
    NSString *keyName;
    if (((notebookId == 606) || (notebookId == 621) || (notebookId == 622)) && (pageNumber > 60)) {
        keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_1", (unsigned int)sectionId, (unsigned int)ownerId, (unsigned int)notebookId];
    }else{
        keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", (unsigned int)sectionId, (unsigned int)ownerId, (unsigned int)notebookId];
    }
    
    NSDictionary *info = [self.notebookInfos objectForKey:keyName];
    
    NPPaperInfo *paperInfo;
    
    if (info != nil) {
        float width = [(NSNumber *)[info objectForKey:@"width"] floatValue];
        float height = [(NSNumber *)[info objectForKey:@"height"] floatValue];
        *x = width;
        *y = height;
        return YES;
    } else {
        paperInfo = [[NPPaperManager sharedInstance] getPaperInfoForNotebookId:notebookId pageNum:pageNumber section:sectionId owner:ownerId];
        
        if (paperInfo != nil) {
            *x = paperInfo.width;
            *y = paperInfo.height;
            return YES;
        } else {
            // Reached here. It means there is no matching information. Just use default one.
            keyName = @"00_00_0000";
            info = [self.notebookInfos objectForKey:keyName];
            if (info == nil) {
                *x = -1.0f;
                *y = -1.0f;
                return NO;
            }
            float width = [(NSNumber *)[info objectForKey:@"width"] floatValue];
            float height = [(NSNumber *)[info objectForKey:@"height"] floatValue];
            *x = width;
            *y = height;
            return YES;
        }
        
    }
}
    
- (BOOL) getPaperDotcodeStartForNotebook:(int)notebookId PageNumber:(int)pageNumber startX:(float *)x startY:(float *)y
{
    // Temporary code. We are getting section id and owner id from a pen.
    // But it's not implemented to use the ids. Have a look at note_paper_info.plist
    unsigned int sectionId = 0;
    unsigned int ownerId = 0;
    if (sectionId == 0 && ownerId == 0) {
        if (notebookId == 1) {
            sectionId = 0;
            ownerId = 19;
        }
        else {
            sectionId = 3;
            ownerId = 27;
        }
    }
    
    UInt32 sectionOwnerID = [self sectionIdAndOwnerIdFromNotebookID:notebookId];
    
    if(sectionOwnerID != 0){
        sectionId = (sectionOwnerID >> 24) & 0xFF;
        ownerId = sectionOwnerID & 0x00FFFFFF;
    }
    
    NSString *keyName;
    if (((notebookId == 606) || (notebookId == 621) || (notebookId == 622)) && (pageNumber > 60)) {
        keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_1", (unsigned int)sectionId, (unsigned int)ownerId, (unsigned int)notebookId];
    }else{
        keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", (unsigned int)sectionId, (unsigned int)ownerId, (unsigned int)notebookId];
    }

    NSDictionary *info = [self.notebookInfos objectForKey:keyName];
    
    NPPaperInfo *paperInfo;
    
    if (info != nil) {
        *x = [(NSNumber *)[info objectForKey:@"startX"] floatValue];
        *y = [(NSNumber *)[info objectForKey:@"startY"] floatValue];
        return YES;
    } else {
        paperInfo = [[NPPaperManager sharedInstance] getPaperInfoForNotebookId:notebookId pageNum:pageNumber section:sectionId owner:ownerId];
        
        if (paperInfo != nil) {
            *x = paperInfo.startX;
            *y = paperInfo.startY;
            return YES;
        } else {
            // Reached here. It means there is no matching information. Just use default one.
            //ken 15.04.25 just return 0
            //keyName = @"00_00_0000";
            //info = [self.notebookInfos objectForKey:keyName];
            //if (info == nil) {
            //    *x = 0.0f;
            //    *y = 0.0f;
            //    return NO;
            //}
            *x = 0.0f;
            *y = 0.0f;
            return NO;
        }
        
    }
    
}
/* Deprecated : This function should not be used. BG has been replaced by dpf. */
- (NSString *) backgroundImageNameForNotebook:(int)notebookId atPage:(int)pageNumber
{
//    NSDictionary *info = [self.notebookInfos objectForKey:[NSNumber numberWithInt:notebookId]];
//    if (info == nil || pageNumber <= 0) return nil;
//    NSString *pageBackground = nil;
//    if (pageNumber == 1) {
//        pageBackground = [info objectForKey:@"page_1"];
//        if (pageBackground != nil) {
//            return pageBackground;
//        }
//    }
//    else if (pageNumber == 2) {
//        pageBackground = [info objectForKey:@"page_2"];
//        if (pageBackground != nil) {
//            return pageBackground;
//        }
//    }
//    
//    if (pageNumber%2 == 0) {
//        pageBackground = [info objectForKey:@"page_even"];
//    }
//    else if (pageNumber%2 == 1) {
//        pageBackground = [info objectForKey:@"page_odd"];
//    }
//    return pageBackground;
    return nil;
}
/* Return background pdf file name. */
- (NSString *) backgroundFileNameForSection:(int)sectionId owner:(UInt32)onwerId note:(UInt32)noteId pageNumber:(UInt32)pageNumber
{
    // Temporary code. We are getting section id and owner id from a pen.
    // But it's not implemented to use the ids. Have a look at note_paper_info.plist
    if (sectionId == 0 && onwerId == 0) {
        if (noteId == 1) {
            sectionId = 0;
            onwerId = 19;
        }
        else {
            sectionId = 3;
            onwerId = 27;
        }
//        else if ((noteId == 501)||(noteId == 502)) {
//            sectionId = 3;
//            onwerId = 109;
//        }
    }
    
    UInt32 sectionOwnerID = [self sectionIdAndOwnerIdFromNotebookID:noteId];
    
    if(sectionOwnerID != 0){
        sectionId = (sectionOwnerID >> 24) & 0xFF;
        onwerId = sectionOwnerID & 0x00FFFFFF;
    }

    NSString *keyName;
    if ((noteId == 617) || (noteId == 618) || (noteId == 619) || (noteId == 700) || (noteId == 701) || (noteId == 702)) {
        if (pageNumber%2 == 0) {
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_1", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        } else if (pageNumber%2 == 1){
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_2", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        }
    } else if (noteId == 615) {
        if (pageNumber == 1) {
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_1", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        } else if ((pageNumber >= 2) && (pageNumber <= 129)){
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_2", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        } else if ((pageNumber >= 130) && (pageNumber <= 256)){
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_3", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        }

    } else if (noteId == 616) {
        if (pageNumber == 1) {
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_1", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        } else if ((pageNumber >= 2) && (pageNumber <= 97)){
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_2", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        } else if ((pageNumber >= 98) && (pageNumber <= 200)){
            keyName = [NSString stringWithFormat:@"%02d_%02d_%04d_3", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
        }
        
    } else {
        keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
    }
    
    NSDictionary *noteInfo = [_notebookInfos objectForKey:keyName];
    
    NSString *fileName = nil;
    if (noteInfo != nil) {
        fileName = [noteInfo objectForKey:@"bgFileName"];
    }
    return fileName;
}
/* Return difference in page number between pdf and note. */
- (int) pdfPageOffsetForSection:(int)sectionId owner:(UInt32)onwerId note:(UInt32)noteId
{
    // Temporary code. We are getting section id and owner id from a pen.
    // But it's not implemented to use the ids. Have a look at note_paper_info.plist
    if (sectionId == 0 && onwerId == 0) {
        if (noteId == 1) {
            sectionId = 0;
            onwerId = 19;
        }
        else {
            sectionId = 3;
            onwerId = 27;
        }
    }
    
    UInt32 sectionOwnerID = [self sectionIdAndOwnerIdFromNotebookID:noteId];
    
    if(sectionOwnerID != 0){
        sectionId = (sectionOwnerID >> 24) & 0xFF;
        onwerId = sectionOwnerID & 0x00FFFFFF;
    }
    
    NSString *keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", (unsigned int)sectionId, (unsigned int)onwerId, (unsigned int)noteId];
    NSDictionary *noteInfo = [_notebookInfos objectForKey:keyName];
    NSNumber *pdfPageOffset = [noteInfo objectForKey:@"pdfPageOffset"];
    if (pdfPageOffset != nil) {
        return [pdfPageOffset integerValue];
    }
    return 0;
}

//NISDK
//- (int) getPaperStartPageNumberForNotebook:(int)notebookId
//{
//    unsigned int sectionId = 0;
//    unsigned int ownerId = 0;
//    if (sectionId == 0 && ownerId == 0) {
//        if (notebookId == 1) {
//            sectionId = 0;
//            ownerId = 19;
//        }
//        else {
//            sectionId = 3;
//            ownerId = 27;
//        }
//    }
//    NSString *keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", (unsigned int)sectionId, (unsigned int)ownerId, (unsigned int)notebookId];
//    NSDictionary *noteInfo = [_notebookInfos objectForKey:keyName];
//    NSNumber *startPageNumber = [noteInfo objectForKey:@"startPageNumber"];
//    if (startPageNumber != nil) {
//        return [startPageNumber integerValue];
//    }
//    return 1;
//}
//not used
- (UInt32) noteIdAt:(int)index
{
    if (index >= self.noteListLength) {
        return 0;
    }
    return notebookTypeArray[index].note_id;
}
//not used
- (UInt32) sectionOwnerIdAt:(int)index
{
    if (index >= self.noteListLength) {
        return 0;
    }
    unsigned char section = notebookTypeArray[index].section_id;
    UInt32 owner = notebookTypeArray[index].owner_id;
    
    return (section << 24) | owner;
}
- (NSArray *) notesSupported
{
    //jr recheck
//    NSMutableArray *tempNoteSupportedFromDB = [[NPPaperManager sharedInstance] notesSupportedFromDB];
//    NSMutableArray *tempNotesSupported = [_notesSupported mutableCopy];
//    [tempNotesSupported addObjectsFromArray:tempNoteSupportedFromDB];
//    _notesSupported = [NSArray arrayWithArray:tempNotesSupported];
    
    return _notesSupported;
}


- (NotebookInfoType) getPaperInfoForNotebook:(int)notebookId
{
    int sectionId;
    UInt32 ownerId;
    
    UInt32 sectionOwnerID = [self sectionIdAndOwnerIdFromNotebookID:notebookId];
    
    if(sectionOwnerID != 0){
        sectionId = (sectionOwnerID >> 24) & 0xFF;
        ownerId = sectionOwnerID & 0x00FFFFFF;
    }
    
    NSString *keyName = [NSString stringWithFormat:@"%02d_%02d_%04d", sectionId, ownerId, notebookId];
    NSDictionary *noteInfo = [_notebookInfos objectForKey:keyName];
    NotebookInfoType notePaperInfo;
    
    if (noteInfo != nil) {
        notePaperInfo.note_id = notebookId;
        notePaperInfo.max_page = [[noteInfo objectForKey:@"pages"] intValue];
        notePaperInfo.width = [[noteInfo objectForKey:@"width"] intValue];
        notePaperInfo.heght = [[noteInfo objectForKey:@"height"] intValue];
    } else {
        NPPaperInfo *paperInfo = [[NPPaperManager sharedInstance] getPaperInfoForNotebookId:notebookId pageNum:1 section:sectionId owner:ownerId];
        notePaperInfo.note_id = notebookId;
        notePaperInfo.max_page = (int)paperInfo.pdfPageNum;
        notePaperInfo.width = (int)paperInfo.width;
        notePaperInfo.heght = (int)paperInfo.height;
    }
    
    return notePaperInfo;
}

- (NSInteger)estimateNoteTypeFromPaperSize:(CGSize)paperSize
{
    NSInteger estimatedNoteType = INT_MAX;
    NSArray *allNoteKeys = [_notebookInfos allKeys];
    CGFloat epsilon = 0.01f;
    
    NSDictionary *noteInfo = nil;
    
    for(NSString *keyName in allNoteKeys) {
        noteInfo = [_notebookInfos objectForKey:keyName];
        CGFloat w = [[noteInfo objectForKey:@"width"] floatValue];
        CGFloat h = [[noteInfo objectForKey:@"height"] floatValue];
        
        if((fabs(w - paperSize.width) <= epsilon) && (fabs(h - paperSize.height) <= epsilon)) {
            NSArray *tokens = [keyName componentsSeparatedByString:@"_"];
            if(tokens && tokens.count >= 3) {
                estimatedNoteType = [[tokens objectAtIndex:2] integerValue];
                break;
            }
        }
        
    }
    if (estimatedNoteType == INT_MAX) {
        estimatedNoteType = [[NPPaperManager sharedInstance] getEstimateNoteTypeFromDB:paperSize];
    }
    
    return estimatedNoteType;
}

@end
