//
//  GameScene.m
//  DragDrop
//
//  Created by Michael Vilabrera on 8/15/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

#import "GameScene.h"

static NSString *const kAnimalNodeName = @"movable";

@interface GameScene ()

@property (nonatomic) SKSpriteNode *background;
@property (nonatomic) SKSpriteNode *selectedNode;

@end

CGFloat degToRad(CGFloat degree) {
    return degree / 180.0f * M_PI;
}

CGPoint mult(const CGPoint v, const CGFloat s) {
    return CGPointMake(v.x*s, v.y*s);
}

@implementation GameScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 1 Load the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"blue-shooting-stars"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        // 2 Load the images
        NSArray *imageNames = @[@"bird", @"cat", @"dog", @"turtle"];
        for (NSInteger i = 0; i < [imageNames count]; i++) {
            NSString *imageName = [imageNames objectAtIndex:i];
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [sprite setName:kAnimalNodeName];
            
            CGFloat offsetFraction = ((float)(i + 1)) / ([imageNames count] + 1);
            [sprite setPosition:CGPointMake(size.width * offsetFraction, size.height / 2)];
            [_background addChild:sprite];
        }
    }
    return  self;
}

//-(void)didMoveToView:(SKView *)view {
//    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self selectNodeForTouch:positionInScene];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    // 1
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    // 2
    if (![_selectedNode isEqual:touchedNode]) {
        [_selectedNode removeAllActions];
        [_selectedNode runAction:[SKAction rotateByAngle:0.0 duration:0.1]];
        
        _selectedNode = touchedNode;
        
        // 3
        if ([[touchedNode name] isEqualToString:kAnimalNodeName]) {
            SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],[SKAction rotateByAngle:0.0 duration:0.1], [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];
            [_selectedNode runAction:[SKAction repeatActionForever:sequence]];
        }
    }
}

- (CGPoint)boundLayerPosition:(CGPoint)newPosition {
    CGSize windowSize = self.size;
    CGPoint retValue = newPosition;
    retValue.x = MIN(retValue.x, 0);
    retValue.x = MAX(retValue.x, -[_background size].width + windowSize.width);
    retValue.y = [self position].y;
    return retValue;
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if ([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    }
    else {
        CGPoint newPosition = CGPointMake(position.x + translation.x, position.y + translation.y);
        [_background setPosition:[self boundLayerPosition:newPosition]];
    }
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPoint previousPosition = [touch previousLocationInNode:self];
    
    CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
    [self panForTranslation:translation];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self selectNodeForTouch:touchLocation];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (![[_selectedNode name] isEqualToString:kAnimalNodeName]) {
            float scrollDuration = 0.2;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            CGPoint position = [_selectedNode position];
            CGPoint p = mult(velocity, scrollDuration);
            
            CGPoint newPosition = CGPointMake(position.x + p.x, position.y + p.y);
            newPosition = [self boundLayerPosition:newPosition];
            [_selectedNode removeAllActions];
            
            SKAction *moveTo = [SKAction moveTo:newPosition duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [_selectedNode runAction:moveTo];
        }
    }
}

@end
