//
//  MainViewController.h
//  NetHack
//
//  Created by dirk on 2/1/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, version 2
 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <UIKit/UIKit.h>
#import "ZDirection.h"

@class NhYnQuestion;
@class NhWindow;
@class ActionViewController;
@class InventoryViewController;
@class NhMenuWindow;
@class MenuViewController;
@class MessageView;
@class MapView;
@class ActionBar;
@class LayeredActionBar;
@class StatusView;

@interface MainViewController : UIViewController <UITextFieldDelegate> {

	IBOutlet MessageView *messageView;
	IBOutlet StatusView *statusView;
	IBOutlet MapView *mapView;
	IBOutlet ActionBar *actionBar;
	IBOutlet LayeredActionBar *layeredActionBar;
	IBOutlet UIScrollView *actionScrollView;
	
	NhYnQuestion *currentYnQuestion;
	ActionViewController *actionViewController;
	InventoryViewController *inventoryViewController;
	MenuViewController *menuViewController;
	
	BOOL directionQuestion;
	
	int clipX;
	int clipY;
	
	UIPopoverController *currentPopover;
	
}

@property (readonly) ActionViewController *actionViewController;
@property (readonly) InventoryViewController *inventoryViewController;
@property (readonly) UINavigationController *inventoryNavigationController;
@property (readonly) MenuViewController *menuViewController;

+ (MainViewController *) instance;

// actions

- (IBAction)toggleMessageView:(id)sender;

// window API

- (void)handleDirectionQuestion:(NhYnQuestion *)q;
- (void)showYnQuestion:(NhYnQuestion *)q;
- (void)refreshMessages;
- (void)showExtendedCommands;

// gets called when core waits for input
- (void)nhPoskey;

- (void)refreshAllViews;

// displays text, always blocking
- (void)displayText:(NSString *)text;

- (void)displayWindow:(NhWindow *)w;
- (void)showMenuWindow:(NhMenuWindow *)w;
- (void)clipAround;
- (void)clipAroundX:(int)x y:(int)y;
- (void)updateInventory;
- (void)getLine;

// touch handling

- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(UIView *)view;
- (void)handleDirectionTap:(e_direction)direction;
- (void)handleDirectionDoubleTap:(e_direction)direction;

// popover

// dismisses any current popovers and prepares that one
- (UIPopoverController *)popoverWithController:(UIViewController *)controller;

// displays the given controller in a popover,
// treating the sender (from an LayeredActionBar action) as CGRect
- (void)displayPopoverWithController:(UIViewController *)controller sender:(id)sender;

@end
