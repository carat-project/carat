//
//  AppLayout.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 30/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#ifndef AppLayout_h
#define AppLayout_h

// layout
#define UI_SCREEN_H ([[UIScreen mainScreen] bounds].size.height)
#define UI_SCREEN_W ([[UIScreen mainScreen] bounds].size.width)
#define UI_STATUS_BAR_HEIGHT            20
#define UI_TOP_NAVIGATION_BAR_HEIGHT    50
#define UI_WINDOW_HEIGHT    (UI_SCREEN_H - UI_STATUS_BAR_HEIGHT)

#endif /* AppLayout_h */
