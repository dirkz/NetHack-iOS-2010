//
//  NhCommand.h
//  SlashEM
//
//  Created by dirk on 1/13/10.
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

#import <Foundation/Foundation.h>
#import "Action.h"
#import "winios.h"

#if !defined IS_TOILET
#define IS_TOILET(typ)  (FALSE)
#endif

#if !defined is_lightsaber
#define is_lightsaber(otmp) (FALSE)
#endif

#ifndef M
# ifndef NHSTDC
#  define M(c)		(0x80 | (c))
# else
#  define M(c)		((c) - 128)
# endif /* NHSTDC */
#endif
#ifndef C
#define C(c)		(0x1f & (c))
#endif

@class NhObject;

@interface NhCommand : Action {
	
	char *keys;

}

@property (nonatomic, readonly) const char *keys;

+ (id)commandWithTitle:(const char *)t keys:(const char *)c;
+ (id)commandWithTitle:(const char *)t key:(char)c;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t key:(char)c;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir;

+ (void)addCommand:(NhCommand *)cmd toCommands:(NSMutableArray *)commands;

// all commands possible at this stage, sorted by category
+ (NSArray *)currentCommands;

// all commands possible for an adjacent position, flat array
+ (NSArray *)commandsForAdjacentTile:(coord)tp;

// direction commands
+ (NSArray *)directionCommands;

- (id)initWithTitle:(const char *)t keys:(const char *)c;
- (id)initWithTitle:(const char *)t key:(char)c;
- (id)initWithObject:(NhObject *)object title:(const char *)t key:(char)c;
- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds;
- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir;

@end
