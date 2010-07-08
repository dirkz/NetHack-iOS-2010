//
//  LayeredActionBar.h
//  NetHack-iOS
//
//  Created by Dirk Zimmermann on 7/8/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayeredActionBar : UIScrollView {

	NSArray *actions;
	NSMutableArray *actionLayers;
	NSInteger highlightedIndex;

}

@property (nonatomic, retain) NSArray *actions;

@end
