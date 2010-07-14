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
@class TileSetViewController;
@class ToolsViewController;
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
	InventoryViewController *inventoryViewController;
	UINavigationController *inventoryNavigationController;
	
	BOOL directionQuestion;
	
	int clipX;
	int clipY;
	
	UIPopoverController *currentPopover;
	
	// old actions the got pushed away
	NSMutableArray *actionStack;
	
}

@property (readonly) ActionViewController *actionViewController;

// cached!
@property (readonly) InventoryViewController *inventoryViewController;

// cached!
@property (readonly) UINavigationController *inventoryNavigationController;

@property (readonly) MenuViewController *menuViewController;
@property (readonly) TileSetViewController *tileSetViewController;
@property (readonly) ToolsViewController *toolsViewController;

// inventory currently shown?
@property (readonly) BOOL isInventoryShown;

@property (readonly) CGSize maxPopoverSize;

+ (MainViewController *) instance;

// actions

- (IBAction)toggleMessageView:(id)sender;

#pragma mark window API

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

#pragma mark misc UI

// sort of like messages from the core, but from the UI :)
- (void)showMessage:(NSString *)msg;

#pragma mark touch handling

- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(UIView *)view;
- (void)handleDirectionTap:(e_direction)direction;
- (void)handleDirectionDoubleTap:(e_direction)direction;

#pragma mark view controller handling

// dismisses any current popovers and prepares that one
- (UIPopoverController *)popoverWithController:(UIViewController *)controller;

// displays the given controller in a popover,
// treating the sender (from an LayeredActionBar action) as CGRect
- (void)displayPopoverWithController:(UIViewController *)controller sender:(id)sender;

- (void)displayPopoverWithController:(UIViewController *)controller mapViewRect:(CGRect)rect;

// sender is supposed to be a NSValue'd action bar CGRect
- (void)showActionMenu:(NSArray *)actions sender:(id)sender dismiss:(BOOL)dismiss;

// decides whether to show popover or modal dialog with the given actions
- (void)showActionMenu:(NSArray *)actions mapViewRect:(CGRect)rect;

// the dismiss decides whether every action should trigger a popover dismiss too on iPad
- (void)showActionMenu:(NSArray *)actions mapViewRect:(CGRect)rect dismiss:(BOOL)dismiss;

// method when your rect comes from the action bar
- (void)showActionMenu:(NSArray *)actions actionBarRect:(CGRect)rect dismiss:(BOOL)dismiss;

// dismisses the given popover without animation, used for selector methods
// that usually don't work gracefully with the original method (because of the BOOL param)
- (void)dismissPopover:(UIPopoverController *)popover;

// shows the given VC either as popover or modal
- (void)showViewController:(UIViewController *)vc sender:(id)sender;

// for use in content VCs
- (void)dismissCurrentPopover;

#pragma mark (Layered)ActionBar

// pushes the given actions into the action bar
- (void)pushActions:(NSArray *)actions;

// restores the original actions
- (void)popActions;

// places/aligns the action bar on the screen
- (void)placeActionBar:(UIView *)actionBar;

@end
