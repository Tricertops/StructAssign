//
//  STRAssignment.h
//  Geografia
//
//  Created by Martin Kiss on 12.8.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _   STRAssign
#define STRAssign(PATH)     STR_assignable.PATH, STRAssignment.current.keypath = @#PATH, STRAssignment.current.CGFloatValue

@class STRAssignable;

@interface STRAssignment : NSObject

+ (instancetype)current;
@property (nonatomic, readwrite, strong) NSObject *object;
@property (nonatomic, readwrite, copy) NSString *keypath;
@property (nonatomic, readwrite, assign) CGFloat CGFloatValue;

+ (void)test;

@end

@interface NSObject (STRAssignment)

- (instancetype)STR_assignable;

@end
