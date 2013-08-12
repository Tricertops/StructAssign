//
//  STRAssignment.m
//  Geografia
//
//  Created by Martin Kiss on 12.8.13.
//  Copyright (c) 2013 iMartin Kiss. All rights reserved.
//

#import "STRAssignment.h"

@interface STRAssignment ()

@property (nonatomic, readwrite, copy) NSString *firstKey;
@property (nonatomic, readwrite, copy) NSString *otherKeys;
@property (nonatomic, readwrite, strong) STRAssignable *assignable;

@end

@interface STRAssignable : NSObject

- (instancetype)initWithObject:(NSObject *)object key:(NSString *)key;

@property (nonatomic, readwrite, strong) NSObject *object;
@property (nonatomic, readwrite, copy) NSString *key;

@end

@interface STRAssignableCGPoint : STRAssignable

@property (nonatomic, readwrite, assign) CGFloat x;
@property (nonatomic, readwrite, assign) CGFloat y;

@end

@interface STRAssignableCGSize : STRAssignable

@property (nonatomic, readwrite, assign) CGFloat width;
@property (nonatomic, readwrite, assign) CGFloat height;

@end

@interface STRAssignableCGRect : STRAssignable

@property (nonatomic, readwrite, strong) STRAssignableCGPoint *origin;
@property (nonatomic, readwrite, strong) STRAssignableCGSize *size;

@property (nonatomic, readwrite, assign) CGFloat x;
@property (nonatomic, readwrite, assign) CGFloat y;
@property (nonatomic, readwrite, assign) CGPoint rawOrigin;
@property (nonatomic, readwrite, assign) CGFloat width;
@property (nonatomic, readwrite, assign) CGFloat height;
@property (nonatomic, readwrite, assign) CGSize rawSize;

@end

@implementation STRAssignment

+ (instancetype)current {
    static STRAssignment *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[STRAssignment alloc] init];
    });
    return shared;
}

- (void)setKeypath:(NSString *)keypath {
    self->_keypath = keypath;
    
    if ( ! keypath.length) return;
    
    NSArray *components = [self.keypath componentsSeparatedByString:@"."];
    self.firstKey = [components objectAtIndex:0];
    self.otherKeys = [[components subarrayWithRange:NSMakeRange(1, components.count-1)] componentsJoinedByString:@"."];
    
    NSValue *value = [self.object valueForKey:self.firstKey];
    if (strcmp(value.objCType, @encode(CGRect)) == 0) {
        self.assignable = [[STRAssignableCGRect alloc] initWithObject:self.object key:self.firstKey];
    }
    else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
        self.assignable = [[STRAssignableCGPoint alloc] initWithObject:self.object key:self.firstKey];
    }
    else if (strcmp(value.objCType, @encode(CGSize)) == 0) {
        self.assignable = [[STRAssignableCGSize alloc] initWithObject:self.object key:self.firstKey];
    }
}

- (CGFloat)CGFloatValue {
    return [[self.assignable valueForKeyPath:self.otherKeys] floatValue];
}

- (void)setCGFloatValue:(CGFloat)CGFloatValue {
    [self.assignable setValue:@(CGFloatValue) forKeyPath:self.otherKeys];
    [self flush];
}

- (void)flush {
    self.object = nil;
    self.assignable = nil;
    self.keypath = nil;
    self.firstKey = nil;
    self.otherKeys = nil;
}

+ (void)test {
    UIScrollView *view = [[UIScrollView alloc] init];
    
    view._(bounds.size.width) = 20;
    
    view._(bounds.size.width) += 20;
    view._(bounds.size.height) = 50;
    
    view._(contentOffset.x) = 20;
    view._(contentSize.height) = 20;
}

@end

@implementation NSObject (STRAssignment)

- (instancetype)STR_assignable {
    STRAssignment.current.object = self;
    return self;
}

@end


@implementation STRAssignable

- (instancetype)initWithObject:(NSObject *)object key:(NSString *)key {
    self = [super init];
    if (self) {
        self.object = object;
        self.key = key;
    }
    return self;
}

@end

#define STRAssignableAccessors(TYPE, STRUCT, GETTER, SETTER, FIELD)\
- (TYPE)GETTER {\
    return [[self.object valueForKey:self.key] STRUCT##Value].FIELD;\
}\
- (void)SETTER:(TYPE)v {\
    STRUCT value = [[self.object valueForKey:self.key] STRUCT##Value];\
    value.FIELD = v;\
    [self.object setValue:[NSValue valueWith##STRUCT:value] forKey:self.key];\
}


@implementation STRAssignableCGPoint

STRAssignableAccessors(CGFloat, CGPoint, x, setX, x)
STRAssignableAccessors(CGFloat, CGPoint, y, setY, y)

@end

@implementation STRAssignableCGSize

STRAssignableAccessors(CGFloat, CGSize, width, setWidth, width)
STRAssignableAccessors(CGFloat, CGSize, height, setHeight, height)

@end

@implementation STRAssignableCGRect

- (instancetype)initWithObject:(NSObject *)object key:(NSString *)key {
    self = [super initWithObject:object key:key];
    if (self) {
        self.origin = [[STRAssignableCGPoint alloc] initWithObject:self key:@"rawOrigin"];
        self.size = [[STRAssignableCGSize alloc] initWithObject:self key:@"rawSize"];
    }
    return self;
}

STRAssignableAccessors(CGFloat, CGRect, x, setX, origin.x)
STRAssignableAccessors(CGFloat, CGRect, y, setY, origin.y)
STRAssignableAccessors(CGPoint, CGRect, rawOrigin, setRawOrigin, origin)
STRAssignableAccessors(CGFloat, CGRect, width, setWidth, size.width)
STRAssignableAccessors(CGFloat, CGRect, height, setHeight, size.height)
STRAssignableAccessors(CGSize, CGRect, rawSize, setRawSize, size)

@end
