//
//  AppColors.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 30/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#ifndef AppColors_h
#define AppColors_h

#define COLOR(c)[UIColor colorWithRed:((c>>24)&0xFF)/255.0      \
green:((c>>16)&0xFF)/255.0    \
blue:((c>>8)&0xFF)/255.0    \
alpha:((c)&0xFF)/255.0]

#define C_CLEAR         [UIColor clearColor];
#define C_DARK_GRAY     COLOR(0x454545ff)
#define C_LIGHT_GRAY    COLOR(0xb4b4b4ff)
#define C_BLACK_BLUE    COLOR(0x122134ff)
#define C_DARK_BLUE     COLOR(0x203e5fff)
#define C_ORANGE        COLOR(0xf7a71bff)
#define C_ORANGE_LIGHT  COLOR(0xfee5b1ff)
#define C_WHITE_DARK    COLOR(0xf5f5f5ff)
#define C_WHITE         COLOR(0xffffffff)
#define C_RED           COLOR(0xf33535ff)

#endif /* AppColors_h */
