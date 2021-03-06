//
//  SnakeGameLayer.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "SnakeGameLayer.h"

@implementation SnakeGameLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	SnakeGameLayer *layer = [SnakeGameLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"theme.wav"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.5f];
        [self setIsTouchEnabled:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Snake Game" message:nil
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self drawBrickWall];
        levelLabel = [CCLabelTTF labelWithString:@"Level Unknown" fontName:@"Marker Felt" fontSize:25];
        levelLabel.color = ccBLACK;
        levelLabel.position =  ccp(160.0, 460.0);
        [self addChild:levelLabel];
        pointsLabel = [CCLabelTTF labelWithString:@"Points Unknown" fontName:@"Marker Felt" fontSize:25];
        pointsLabel.color = ccBLUE;
        pointsLabel.position =  ccp(260.0, 460.0);
        [self addChild:pointsLabel];
        [self resetGame];
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
    [self resetGame];
}

- (void) resetGame
{
    level = 1;
    levelLabel.string = [NSString stringWithFormat:@"Level %i", level];
    points = 0;
    pointsLabel.string = [NSString stringWithFormat:@"%i", points];
    startX = 20 * 5;
    startY = 20 * 2;
    direction = @"Forward";
    lengthOfSnake = 4;
    [self initializeSnakeArray];
    [self createItem];
    gamePaused = YES;
}

- (void) refresh: (ccTime)t
{
    [self updateSnakeArray];
    if (snake[0].x == 0 || snake[0].x == 300)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [self unschedule:@selector(refresh:)];
        alert.message = @"Boundary Reached!";
        [alert show];
    }
    else if (snake[0].y == 20 || snake[0].y == 460)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        [self unschedule:@selector(refresh:)];
        alert.message = @"Boundary Reached!";
        [alert show];
    }
    for (int i = 1; i < lengthOfSnake; i++)
    {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
            [self unschedule:@selector(refresh:)];
            alert.message = @"Self-intersection detected!";
            [alert show];
        }
    }
    if (snake[0].x == item.x && snake[0].y == item.y)
    {
        NSLog(@"Item collected!");
        points++;
        pointsLabel.string = [NSString stringWithFormat:@"%i", points];
        [[SimpleAudioEngine sharedEngine] playEffect:@"collect.wav"];
        snake[lengthOfSnake] = CGPointMake(-20.0, -20.0);
        lengthOfSnake++;
        [self createItem];
    }
}

- (void) drawBackground
{
    glColor4f(0.0, 0.0, 0.5, 1.0);
    CGPoint startPoint = CGPointMake(0.0, 480.0);
    CGPoint endPoint = CGPointMake(320.0, 0.0);
    ccDrawSolidRect(startPoint, endPoint);
}

- (void) drawGrid
{
    // Tell OpenGL which color to use
    glColor4f(0.5, 0.5, 0.5, 1.0);
    for (int i = 0; i < 16; i++)
    {
        float x = 20 * i;
        ccDrawLine(CGPointMake(x, 0.0), CGPointMake(x, 480.0));
    }
    for (int j = 0; j < 24; j++)
    {
        float y = 20 * j;
        ccDrawLine(CGPointMake(0.0, y), CGPointMake(320.0, y));
    }
}

- (void) drawSnake
{
    // Tell OpenGL which color to use
    for (int i = 0; i < lengthOfSnake; i++)
    {
        CGPoint startPoint = CGPointMake(snake[i].x, snake[i].y);
        CGPoint endPoint = CGPointMake(snake[i].x + 20, snake[i].y - 20);
        glColor4f((lengthOfSnake-i)/(float)lengthOfSnake, 1.0, 0.0, 1.0);
        ccDrawSolidRect(startPoint, endPoint);
    }
}

- (void) drawItem
{
    CGPoint startPoint = CGPointMake(item.x, item.y);
    CGPoint endPoint = CGPointMake(item.x + 20, item.y - 20);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    ccDrawSolidRect(startPoint, endPoint);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    ccDrawRect(startPoint, endPoint);
}

- (void) drawBrickWall
{
    for (int j = 1; j < 25; j++)
    {
        for (int i = 0; i < 16; i++)
        {
            if (j == 1 || j > 22 || ((j > 0 && j < 23) && (i == 0 || i == 15)))
            {
                CCSprite *stone = [CCSprite spriteWithFile:@"stone.gif"];
                stone.position = CGPointMake(20*i + 10, 20*j - 10);
                [self addChild:stone];
            }
        }
    }
}

// Drawing the graph and the axes
- (void) draw
{
    // Tell OpenGL that you intend to draw a line segment
    glEnable(GL_LINE_SMOOTH);
    // Determine if retina display is enabled and tell OpenGL to set the line width accordingly
    if (CC_CONTENT_SCALE_FACTOR() == 1.0)
    {
        glLineWidth(1.0f);
    }
    else
    {
        glLineWidth(2.0f);
    }
    [self drawBackground];
    [self drawSnake];
    [self drawGrid];
    [self drawItem];
    // Tell OpenGL to reset the color (to avoid scene transition tint effect)
    glColor4f(1.0, 1.0, 1.0, 1.0);
    // Tell OpenGL that you have finished drawing
    glDisable(GL_LINE_SMOOTH);
}

- (void) updateSnakeArray
{
    for (int i = lengthOfSnake-1; i > 0; i--)
    {
        snake[i] = snake[i-1];
    }
    if ([direction isEqualToString:@"Forward"])
    {
        float x = snake[0].x+20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Backward"])
    {
        float x = snake[0].x-20;
        float y = snake[0].y;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Downward"])
    {
        float x = snake[0].x;
        float y = snake[0].y-20;
        snake[0] = CGPointMake(x, y);
    }
    else if ([direction isEqualToString:@"Upward"])
    {
        float x = snake[0].x;
        float y = snake[0].y+20;
        snake[0] = CGPointMake(x, y);
    }
}

- (void) initializeSnakeArray
{
    for (int i = 0; i < lengthOfSnake; i++)
    {
        snake[i] = CGPointMake(startX-20*i, startY);
    }
}

- (void) createItem
{
    CGPoint position;
    BOOL validPosition = NO;
    while (!validPosition)
    {
        int x = arc4random() % 14 + 1;
        int y = arc4random() % 21 + 2;
        position = CGPointMake(20.0 * x, 20.0 * y);
        for (int j = 0; j < lengthOfSnake; j++)
        {
            if (position.x == snake[j].x && position.y == snake[j].y)
            {
                break;
            }
            else if (j == lengthOfSnake-1)
            {
                item = position;
                validPosition = YES;
            }
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (gamePaused)
    {
        gamePaused = NO;
        [self schedule:@selector(refresh:) interval:0.175];
        return;
    }
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    // Update direction of snake motion based on touch location
    if ([direction isEqualToString:@"Forward"] || [direction isEqualToString:@"Backward"])
    {
        if (location.y > snake[0].y)
        {
            direction = @"Upward";
        }
        else if (location.y < snake[0].y - 20.0)
        {
            direction = @"Downward";
        }
    }
    else if ([direction isEqualToString:@"Upward"] || [direction isEqualToString:@"Downward"])
    {
        if (location.x > snake[0].x + 20.0)
        {
            direction = @"Forward";
        }
        else if (location.x < snake[0].x)
        {
            direction = @"Backward";
        }
    }
}

- (void) dealloc
{
	[super dealloc];
}
@end
