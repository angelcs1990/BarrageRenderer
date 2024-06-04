// Part of BarrageRenderer. Created by UnAsh.
// Blog: http://blog.exbye.com
// Github: https://github.com/unash/BarrageRenderer

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015年 UnAsh.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BarrageSpriteQueue.h"
#import "BarrageSprite.h"

@interface BarrageSpriteQueue ()
@property(nonatomic,strong,readonly)NSMutableArray<BarrageSprite *> *sprites; // 增序排列
- (instancetype)initWithAscendingSprites:(NSArray<BarrageSprite *> *)sprites vipSprites: (NSArray<BarrageSprite *> *)vipSprites;

@property (nonatomic, strong, readonly) NSMutableArray<BarrageSprite *> *vipSprites;

@end

@implementation BarrageSpriteQueue

- (instancetype)init
{
    return [self initWithAscendingSprites:nil vipSprites:nil];
}

- (instancetype)initWithAscendingSprites:(NSArray<BarrageSprite *> *)sprites vipSprites:(NSArray<BarrageSprite *> *)vipSprites
{
    if (self = [super init]) {
        _sprites = sprites?[sprites mutableCopy]:[NSMutableArray new];
        _vipSprites = vipSprites ? [vipSprites mutableCopy] : [NSMutableArray array];
    }
    return self;
}

#pragma mark - interface

- (void)addSprite:(BarrageSprite *)sprite
{
    NSInteger index = [self indexForSprite:sprite];
    if (sprite.isVip) {
        [self.vipSprites insertObject:sprite atIndex:index];
    } else {
        [self.sprites insertObject:sprite atIndex:index];
    }
}

- (NSArray *)ascendingSprites
{
    NSMutableArray *retTmp = [NSMutableArray arrayWithArray:[self.vipSprites copy]];
    [retTmp addObjectsFromArray:[self.sprites copy]];
    return [retTmp copy];
}

- (NSArray *)descendingSprites
{
    NSMutableArray *retTmp = [NSMutableArray arrayWithArray:[[self.vipSprites reverseObjectEnumerator] allObjects]];
    [retTmp addObjectsFromArray:[[self.sprites reverseObjectEnumerator] allObjects]];
    return retTmp.copy;
}

- (void)removeSprite:(BarrageSprite *)sprite
{
    if (sprite.isVip) {
        [self.vipSprites removeObject:sprite];
    } else {
        [self.sprites removeObject:sprite];
    }
}

- (void)removeSprites:(NSArray<BarrageSprite *> *)sprites
{
    NSMutableArray *tmpVip = [NSMutableArray array];
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (BarrageSprite *item in sprites) {
        if (item.isVip) {
            [tmpVip addObject:item];
        } else {
            [tmp addObject:item];
        }
    }
    
    if (tmpVip.count > 0) {
        [self.vipSprites removeObjectsInArray:tmpVip];
    } else {
        [self.sprites removeObjectsInArray:tmp];
    }
}

- (instancetype)spriteQueueWithDelayLessThanOrEqualTo:(NSTimeInterval)delay
{
    return [self spriteQueueWithDelayLessThan:delay equal:YES];
}

- (instancetype)spriteQueueWithDelayLessThan:(NSTimeInterval)delay
{
    return [self spriteQueueWithDelayLessThan:delay equal:NO];
}

- (instancetype)spriteQueueWithDelayLessThan:(NSTimeInterval)delay equal:(BOOL)equal
{
    NSInteger total = self.sprites.count;
    NSInteger index = [self delayLessThan:delay equal:equal isVip:FALSE];
    
    NSInteger totalVip = self.vipSprites.count;
    NSInteger indexVip = [self delayLessThan:delay equal:equal isVip:TRUE];
    
    if (index < 1 && indexVip < 1) {
        return [[BarrageSpriteQueue alloc]init];
    } else {
        NSArray *subArray = nil;
        NSArray *subArrayVip = nil;
        if (index >= 1) {
            subArray = [self.sprites subarrayWithRange:NSMakeRange(0, index)];
        }
        if (indexVip >= 1) {
            subArrayVip = [self.vipSprites subarrayWithRange:NSMakeRange(0, indexVip)];
        }
        return [[BarrageSpriteQueue alloc] initWithAscendingSprites:subArray vipSprites:subArrayVip];
    }
}

- (instancetype)spriteQueueWithDelayGreaterThanOrEqualTo:(NSTimeInterval)delay
{
    return [self spriteQueueWithDelayGreaterThan:delay equal:YES];
}

- (instancetype)spriteQueueWithDelayGreaterThan:(NSTimeInterval)delay
{
    return [self spriteQueueWithDelayGreaterThan:delay equal:NO];
}

- (instancetype)spriteQueueWithDelayGreaterThan:(NSTimeInterval)delay equal:(BOOL)equal
{
    NSInteger total = self.sprites.count;
    NSInteger index = [self delayGreaterThan:delay equal:equal isVip:FALSE];
    
    NSInteger totalVip = self.vipSprites.count;
    NSInteger indexVip = [self delayGreaterThan:delay equal:equal isVip:TRUE];
    
    if (index >= total-1 && indexVip >= totalVip - 1) {
        return [[BarrageSpriteQueue alloc] init];
    } else {
        NSArray *subArray = nil;
        NSArray *subArrayVip = nil;
        if (index >= 1) {
            subArray = [self.sprites subarrayWithRange:NSMakeRange(index+1, total-index-1)];
        }
        if (indexVip >= 1) {
            subArrayVip = [self.vipSprites subarrayWithRange:NSMakeRange(indexVip + 1, totalVip - indexVip - 1)];
        }
        
        return [[BarrageSpriteQueue alloc] initWithAscendingSprites:subArray vipSprites:subArrayVip];
    }
}

- (NSInteger)delayGreaterThan:(NSTimeInterval)delay equal:(BOOL)equal isVip:(BOOL)isVip {
    NSArray<BarrageSprite *> *tmpSprites = isVip ? self.vipSprites : self.sprites;
    
    NSInteger total = tmpSprites.count;
    NSInteger index = [self indexForSpriteDelay:delay isVip:isVip];
    index--;
    while (index >= 0) {
        BarrageSprite *sprite = tmpSprites[index];
        if ((equal && sprite.delay < delay)||(!equal && sprite.delay<=delay)) {
            break;
        } else {
            index--;
        }
    }
    while (!equal && index<total-1 && tmpSprites[index+1].delay==delay) {
        index++;
    }
    
    return index;
}

- (NSInteger)delayLessThan:(NSTimeInterval)delay equal:(BOOL)equal isVip:(BOOL)isVip {
    NSArray<BarrageSprite *> *tmpSprites = isVip ? self.vipSprites : self.sprites;
    
    NSInteger total = tmpSprites.count;
    NSInteger index = [self indexForSpriteDelay:delay isVip:isVip];
    while (index <= total-1) {
        BarrageSprite *sprite = tmpSprites[index];
        if ((equal && sprite.delay > delay)||(!equal && sprite.delay>=delay)) {
            break;
        } else {
            index++;
        }
    }
    while (!equal && index>0 && tmpSprites[index-1].delay==delay) {
        index--;
    }
    
    return index;
}

#pragma mark - util

// 找到则返回元素在数组中的下标，如果没找到，则返回这个元素在有序数组中的位置
- (NSInteger)indexForSpriteDelay:(NSTimeInterval)delay isVip:(BOOL)isVip
{
    NSArray *tmpSprites = isVip ? self.vipSprites : self.sprites;
    NSInteger min = 0;
    NSInteger max = tmpSprites.count - 1;
    NSInteger mid = 0;
    while (min <= max) {
        mid = (min + max) >> 1;
        BarrageSprite *baseSprite = tmpSprites[mid];
        if (delay > baseSprite.delay) {
            min = mid + 1;
        } else if (delay < baseSprite.delay) {
            max = mid - 1;
        } else {
            return mid;
        }
    }
    return min;
}

- (NSInteger)indexForSprite:(BarrageSprite *)sprite
{
    return [self indexForSpriteDelay:sprite.delay isVip:sprite.isVip];
}

@end
