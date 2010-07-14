//
//  ToolViewController.m
//  NetHack
//
//  Created by Dirk Zimmermann on 2/28/10.
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

#import "ToolsViewController.h"
#import "NhObject.h"
#import "TileSet.h"
#import "NhEventQueue.h"
#import "NhEvent.h"
#import "MainViewController.h"

#include "hack.h"

@implementation ToolsViewController

@synthesize tableView = tv;

#pragma mark -
#pragma mark Initialization

- (void)updateInventory {
	for (struct obj *otmp = invent; otmp; otmp = otmp->nobj) {
		if (otmp->oclass == TOOL_CLASS) {
			[items addObject:[NhObject objectWithObject:otmp]];
		}
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		items = [[NSMutableArray alloc] init];
		[self updateInventory];
    }
    return self;
}

- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark popover

- (CGSize)contentSizeForViewInPopover {
	return CGSizeMake(300.0f, items.count * 44.0f);
}

#pragma mark properties

- (NSArray *)items {
	return items;
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NhObject *item = [items objectAtIndex:indexPath.row];
	if (item.inventoryLetter != '-') {
		cell.textLabel.text = [NSString stringWithFormat:@"%c - %@", item.inventoryLetter, item.title];
	} else {
		cell.textLabel.text = item.title;
	}
	cell.detailTextLabel.text = item.detail;
	
	if (item.glyph && item.glyph != NO_GLYPH) {
		CGImageRef img = [[TileSet instance] imageForGlyph:item.glyph];
		cell.imageView.image = [UIImage imageWithCGImage:img];
	} else {
		cell.imageView.image = nil;
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NhObject *item = [items objectAtIndex:indexPath.row];
	char cmd[3];
	sprintf(cmd, "a%c", item.inventoryLetter);
	[[NhEventQueue instance] addKeys:cmd];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[[MainViewController instance] dismissCurrentPopover];
	} else {
		[self dismissModalViewControllerAnimated:NO];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[items release];
    [super dealloc];
}

@end