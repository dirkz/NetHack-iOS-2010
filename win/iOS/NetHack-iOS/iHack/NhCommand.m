//
//  NhCommand.m
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

#import "NhCommand.h"
#import "NhEventQueue.h"
#import "NhObject.h"

#include "hack.h"

@implementation NhCommand

+ (id)commandWithTitle:(const char *)t keys:(const char *)c {
	return [[[self alloc] initWithTitle:t keys:c] autorelease];
}

+ (id)commandWithTitle:(const char *)t key:(char)c {
	return [[[self alloc] initWithTitle:t key:c] autorelease];
}

+ (id)commandWithObject:(NhObject *)object title:(const char *)t key:(char)c {
	return [[[self alloc] initWithObject:object title:t key:c] autorelease];
}

+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds {
	return [[[self alloc] initWithObject:object title:t keys:cmds] autorelease];
}

+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir {
	return [[[self alloc] initWithObject:object title:t keys:cmds direction:dir] autorelease];
}

- (id)initWithTitle:(const char *)t keys:(const char *)c {
	if (self = [super init]) {
		title = [[NSString alloc] initWithCString:t encoding:NSASCIIStringEncoding];
		keys = malloc(strlen(c)+1);
		strcpy(keys, c);
	}
	return self;
}

+ (void)addCommand:(NhCommand *)cmd toCommands:(NSMutableArray *)commands {
	if (![commands containsObject:cmd]) {
		[commands addObject:cmd];
	}
}

enum InvFlags {
	fWieldedWeapon = 1,
	fWand = 2,
	fReadable = 4,
	fWeapon = 8,
	fAppliable = 16,
	fEdible = 64,
	fCorpse = 128,
	fUnpaid = 256,
	fTinningKit = 512,
	fAthameWielded = 1024, // athame wielded
};

enum GroundFlags {
	fEngraved = 1, // something readable on the ground, engraved or written in the dust
	fDustWritten = 2, // like fEngraved but written in the dust
};

+ (NSArray *)currentCommands {
	NSMutableArray *commands = [NSMutableArray array];
	int inv = 0;
	int ground = 0;
	struct obj *oTinningKit = NULL;
	struct obj *oCorpse = NULL; // corpse lying around
	struct obj *oWieldedWeapon = NULL;

	for (struct obj *otmp = invent; otmp; otmp = otmp->nobj) {
		if (otmp->unpaid) {
			inv |= fUnpaid;
		}
		switch (otmp->oclass) {
			case WAND_CLASS:
				inv |= fWand;
				break;
			case SPBOOK_CLASS:
			case SCROLL_CLASS:
				inv |= fReadable;
				break;
			case WEAPON_CLASS:
				if (otmp->owornmask & W_WEP) {
					inv |= fWieldedWeapon;
					oWieldedWeapon = otmp;
					if (otmp->otyp == ATHAME) {
						inv |= fAthameWielded;
					}
				}
				inv |= fWeapon;
				break;
			case TOOL_CLASS:
				if (otmp->otyp == TINNING_KIT) {
					inv |= fTinningKit;
					oTinningKit = otmp;
				}
				// activated lightsabers act the same as a wielded weapon (#force)
				if (otmp->owornmask & W_WEP && is_lightsaber(otmp) && otmp->lamplit) {
					inv |= fWieldedWeapon;
					oWieldedWeapon = otmp;
				}
			case POTION_CLASS:
				inv |= fAppliable;
				break;
			case FOOD_CLASS:
				inv |= fEdible;
				if (otmp->otyp == CORPSE) {
					inv |= fCorpse;
				}
				break;

			default:
				break;
		}
	}
	
	if ((u.ux == xupstair && u.uy == yupstair)
		|| (u.ux == sstairs.sx && u.uy == sstairs.sy && sstairs.up)
		|| (u.ux == xupladder && u.uy == yupladder)) {
		[self addCommand:[NhCommand commandWithTitle:"Up" key:'<'] toCommands:commands];
	} else if ((u.ux == xdnstair && u.uy == ydnstair)
			   || (u.ux == sstairs.sx && u.uy == sstairs.sy && !sstairs.up)
			   || (u.ux == xdnladder && u.uy == ydnladder)) {
		[self addCommand:[NhCommand commandWithTitle:"Down" key:'>'] toCommands:commands];
	}
	
	// objects lying on the floor
	struct obj *object = level.objects[u.ux][u.uy];
	if (object) {
		[self addCommand:[NhCommand commandWithTitle:"Pickup" key:','] toCommands:commands];
		[self addCommand:[NhCommand commandWithTitle:"What's here" key:':'] toCommands:commands];
		while (object) {
			if (Is_container(object)) {
				if (Is_box(object)) { // not a bag or medkit
					char cmdUntrapDown[] = {M('u'), '>', 'y', 0};
					[self addCommand:[NhCommand commandWithTitle:"Untrap Container" keys:cmdUntrapDown]
						  toCommands:commands];
					if (object->olocked) {
						if (inv & fWieldedWeapon) {
							char forceDown[] = {M('f'), '>', 'y', 0};
							[self addCommand:[NhCommand commandWithTitle:"Force Container" keys:forceDown]
								  toCommands:commands];
						}
						if (inv & fAppliable) {
							[self addCommand:[NhCommand commandWithTitle:"Apply" key:'a']
								  toCommands:commands];
						}
					} else {
						char cmdLoot[] = {M('l'), 'y', 0};
						[self addCommand:[NhCommand commandWithTitle:"Loot Container" keys:cmdLoot] toCommands:commands];
					}
				} else { // bags, medkit etc.
					char cmdLoot[] = {M('l'), 'y', 0};
					[self addCommand:[NhCommand commandWithTitle:"Loot Container" keys:cmdLoot] toCommands:commands];
				}
			} else if (is_edible(object)) {
#if SLASHEM
				[self addCommand:[NhCommand commandWithTitle:"Eat what's here" keys:"e,"]
					  toCommands:commands];
#else
				[self addCommand:[NhCommand commandWithTitle:"Eat" keys:"e"]
					  toCommands:commands];
#endif
				if (object->otyp == CORPSE) {
					oCorpse = object;
					if (inv & fTinningKit) {
						NhObject *tinningKit = [NhObject objectWithObject:oTinningKit];
#if SLASHEM
						[self addCommand:[NhCommand commandWithObject:tinningKit title:"Tin what's here" keys:"a" direction:","]
							  toCommands:commands];
#else
						[self addCommand:[NhCommand commandWithObject:tinningKit title:"Tin" keys:"a"]
							  toCommands:commands];
#endif
					}
				}
			}
			struct obj *otmp = shop_object(u.ux, u.uy);
			if (otmp) {
				[self addCommand:[NhCommand commandWithTitle:"Chat" key:M('c')]
					  toCommands:commands];
			}
			object = object->nexthere;
		}
	}
	
	struct engr *ep = engr_at(u.ux, u.uy);
	if (ep) {
		ground |= fEngraved; // not really inventory
		if (ep->engr_type == DUST) {
			ground |= fDustWritten;
		}
	}
	
	if (ground & fEngraved) {
#if SLASHEM
		[self addCommand:[NhCommand commandWithTitle:"Read what's here" keys:"r."] toCommands:commands];
#else
		[self addCommand:[NhCommand commandWithTitle:"What's here" keys:":"] toCommands:commands];
#endif
	}
	
	if (IS_ALTAR(levl[u.ux][u.uy].typ)) {
		[self addCommand:[NhCommand commandWithTitle:"What's here" key:':'] toCommands:commands];
		if (inv & fCorpse) {
			[self addCommand:[NhCommand commandWithTitle:"Offer" key:M('o')] toCommands:commands];
		}
		if (oCorpse) {
			char cmd[] = { M('o'), ',', 0 };
			[self addCommand:[NhCommand commandWithTitle:"Offer what's here" keys:cmd] toCommands:commands];
		}
	}
	if (IS_FOUNTAIN(levl[u.ux][u.uy].typ) || IS_SINK(levl[u.ux][u.uy].typ) || IS_TOILET(levl[u.ux][u.uy].typ)) {
		[self addCommand:[NhCommand commandWithTitle:"What's here" key:':'] toCommands:commands];
#if SLASHEM
		[self addCommand:[NhCommand commandWithTitle:"Quaff" keys:"q."] toCommands:commands];
#else
		[self addCommand:[NhCommand commandWithTitle:"Quaff" keys:"q"] toCommands:commands];
#endif
		[self addCommand:[NhCommand commandWithTitle:"Dip" key:M('d')] toCommands:commands];
	}
	if (IS_THRONE(levl[u.ux][u.uy].typ)) {
		[self addCommand:[NhCommand commandWithTitle:"What's here" key:':'] toCommands:commands];
		[self addCommand:[NhCommand commandWithTitle:"Sit" key:M('s')] toCommands:commands];
	}
	
	if (oWieldedWeapon) {
		NhObject *wieldedWeapon = [NhObject objectWithObject:oWieldedWeapon];
		[self addCommand:[NhCommand commandWithObject:wieldedWeapon title:"Apply wielded weapon" keys:"a"]
			  toCommands:commands]; 
	}
	
	struct trap *t = t_at(u.ux, u.uy);
	if (t) {
		// todo check for knowledge about trap
		[self addCommand:[NhCommand commandWithTitle:"Untrap" key:M('u')] toCommands:commands];
		[self addCommand:[NhCommand commandWithTitle:"Identify Trap" key:'^'] toCommands:commands];
	}

	int positions[][2] = {
		{ u.ux, u.uy-1 },
		{ u.ux, u.uy+1 },
		{ u.ux-1, u.uy-1 },
		{ u.ux-1, u.uy+1 },
		{ u.ux+1, u.uy-1 },
		{ u.ux+1, u.uy+1 },
		{ u.ux-1, u.uy },
		{ u.ux+1, u.uy },
	};
	for (int i = 0; i < 8; ++i) {
		int tx = positions[i][0];
		int ty = positions[i][1];
		if (tx > 0 && ty > 0 && tx < COLNO && ty < ROWNO) {
			if (IS_DOOR(levl[tx][ty].typ)) {
				int mask = levl[tx][ty].doormask;
				if (mask & D_ISOPEN) {
					[self addCommand:[NhCommand commandWithTitle:"Close" key:'c'] toCommands:commands];
				} else {
					if (mask & D_CLOSED) {
						[self addCommand:[NhCommand commandWithTitle:"Open" key:'o'] toCommands:commands];
					} else if (mask & D_LOCKED) {
						if (inv & fWieldedWeapon) {
							[self addCommand:[NhCommand commandWithTitle:"Force" key:M('f')] toCommands:commands];
						}
						if (inv & fAppliable) {
							[self addCommand:[NhCommand commandWithTitle:"Apply" key:'a'] toCommands:commands];
						}
					}
					// if polymorphed into something that can't open doors, kick should there for either door mask
					[self addCommand:[NhCommand commandWithTitle:"Kick" key:C('d')] toCommands:commands];
				}
			}
			struct trap *t = t_at(tx, ty);
			if (t) {
				// todo check for knowledge about trap
				[self addCommand:[NhCommand commandWithTitle:"Untrap" key:M('u')] toCommands:commands];
				[self addCommand:[NhCommand commandWithTitle:"Identify Trap" key:'^'] toCommands:commands];
			}
			struct monst *mtmp = m_at(tx, ty);
			if (mtmp) {
				[self addCommand:[NhCommand commandWithTitle:"Chat" key:M('c')] toCommands:commands];
			}
		}
	}
	
	[self addCommand:[NhCommand commandWithTitle:"Kick" key:C('d')] toCommands:commands];
	
	// automatic E-Word
	char ewordCmd[20];
	BOOL ewordPossible = NO;
	const char *ewordMeans = "Fingers";
	if (ground & fEngraved) {
		if (inv & fAthameWielded) {
			ewordPossible = YES;
			ewordMeans = xname(oWieldedWeapon);
			if (ground & fDustWritten) {
				sprintf(ewordCmd, "E%cElbereth\n", oWieldedWeapon->invlet);
			} else {
				sprintf(ewordCmd, "E%cnElbereth\n", oWieldedWeapon->invlet);
			}
		} else if (ground & fDustWritten) {
			ewordPossible = YES;
			strcpy(ewordCmd, "E-nElbereth\n");
		}
	} else {
		if (inv & fAthameWielded) {
			ewordPossible = YES;
			sprintf(ewordCmd, "E%cElbereth\n", oWieldedWeapon->invlet);
		} else {
			ewordPossible = YES;
			strcpy(ewordCmd, "E-Elbereth\n");
		}
	}
	if (ewordPossible) {
		char ewordTitle[40];
		sprintf(ewordTitle, "E-Word (%s)", ewordMeans);
		[self addCommand:[NhCommand commandWithTitle:ewordTitle keys:ewordCmd] toCommands:commands];
	}
	
	if (inside_shop(u.ux, u.uy)) {
		[self addCommand:[NhCommand commandWithTitle:"Pay" key:'p'] toCommands:commands];
	}
	
	[self addCommand:[NhCommand commandWithTitle:"Pray" key:M('p')] toCommands:commands];
	[self addCommand:[NhCommand commandWithTitle:"Rest 19 turns" keys:"19."] toCommands:commands];
	[self addCommand:[NhCommand commandWithTitle:"Rest 99 turns" keys:"99."] toCommands:commands];

	return commands;
}

+ (NhCommand *)directionCommandWithTitle:(const char *)t key:(char)key direction:(char)d {
	char cmd[3] = { key, d, '\0' };
	return [NhCommand commandWithTitle:t keys:cmd];
}

+ (NSArray *)commandsForAdjacentTile:(coord)tp {
	NSMutableArray *commands = [NSMutableArray array];
	coord nhDelta = CoordMake(tp.x-u.ux, tp.y-u.uy);
	int dir = xytod(nhDelta.x, nhDelta.y);
	char direction = sdir[dir];
	if (tp.x > 0 && tp.y > 0 && tp.x < COLNO && tp.y < ROWNO) {
		if (IS_DOOR(levl[tp.x][tp.y].typ)) {
			int mask = levl[tp.x][tp.y].doormask;
			if (mask & D_ISOPEN) {
				[self addCommand:[self directionCommandWithTitle:"Close" key:'c' direction:direction]
					  toCommands:commands];
				[self addCommand:[NhCommand commandWithTitle:"Move" key:direction] toCommands:commands];
			} else {
				if (mask & D_CLOSED) {
					[self addCommand:[self directionCommandWithTitle:"Open" key:'o' direction:direction]
						  toCommands:commands];
					[self addCommand:[self directionCommandWithTitle:"Kick" key:C('d') direction:direction]
						  toCommands:commands];
				} else if (mask & D_LOCKED) {
					[self addCommand:[NhCommand commandWithTitle:"Force" key:M('f')]
						  toCommands:commands];
					[self addCommand:[NhCommand commandWithTitle:"Apply" key:'a']
						  toCommands:commands];
					[self addCommand:[self directionCommandWithTitle:"Kick" key:C('d') direction:direction]
						  toCommands:commands];
				}
			}
		}
		struct trap *t = t_at(tp.x, tp.y);
		if (t) {
			[self addCommand:[self directionCommandWithTitle:"Untrap" key:M('u') direction:direction]
				  toCommands:commands];
		}
		struct monst *mtmp = m_at(tp.x, tp.y);
		if (mtmp) {
			[self addCommand:[self directionCommandWithTitle:"Chat" key:M('c') direction:direction]
				  toCommands:commands];
			[self addCommand:[NhCommand commandWithTitle:"Move" key:direction] toCommands:commands];
		}
	}
	return commands;
}

+ (NSArray *)directionCommands {
	return [NSArray arrayWithObjects:
			[NhCommand commandWithTitle:"Down >" key:'>'],
			[NhCommand commandWithTitle:"Up <" key:'<'],
			[NhCommand commandWithTitle:"Self ." key:'.'],
			[NhCommand commandWithTitle:"Cancel" key:'\033'],
			nil];
}

- (id)initWithTitle:(const char *)t key:(char)c {
	char cmd[] = { c, '\0' };
	return [self initWithTitle:t keys:cmd];
}

- (id)initWithObject:(NhObject *)object title:(const char *)t key:(char)c {
	char cmd[3] = { c, '\0', '\0' };
	cmd[1] = object.inventoryLetter;
	return [self initWithTitle:t keys:cmd];
}

- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds {
	int keysLen = strlen(cmds);
	char cmd[keysLen + 2]; // room for inv letter and terminal 0
	sprintf(cmd, "%s%c", cmds, object.inventoryLetter);
	return [self initWithTitle:t keys:cmd];
}

- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir {
	int keysLen = strlen(cmds) + strlen(dir);
	char cmd[keysLen + 2]; // room for inv letter and terminal 0
	sprintf(cmd, "%s%c%s", cmds, object.inventoryLetter, dir);
	return [self initWithTitle:t keys:cmd];
}

- (const char *)keys {
	return (const char *) keys;
}

- (void)dealloc {
	free(keys);
	[super dealloc];
}

#pragma mark Action

- (NSString *)title {
	return title;
}

- (void)invoke:(id)sender {
	[[NhEventQueue instance] addCommand:self];
	[super invoke:sender];
}

- (BOOL)isEqual:(id)anObject {
	if ([self class] != [anObject class]) {
		return NO;
	}
	NhCommand *cmd = (NhCommand *)anObject;
	if (self.keys == cmd.keys) {
		return YES;
	}
	if (self.keys == NULL || cmd.keys == NULL) {
		return NO;
	}
	if (!strcmp(self.keys, cmd.keys)) {
		return YES;
	} else {
		return NO;
	}
}

- (NSUInteger)hash {
	return [[NSString stringWithCString:self.keys encoding:NSASCIIStringEncoding] hash];
}

@end