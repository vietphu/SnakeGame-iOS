//
//  SnakeGameLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer
@interface SnakeGameLayer : CCLayer <UIAlertViewDelegate>
{
    float startX, startY;
	NSString *direction;
	CGPoint snake[50];
    CGPoint item;
	int lengthOfSnake;
    UIAlertView *alert;
    BOOL gamePaused;
    CCLabelTTF *levelLabel;
    CCLabelTTF *pointsLabel;
    int level;
    int points;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) resetGame;
- (void) drawBackground;
- (void) drawGrid;
- (void) drawSnake;
- (void) drawItem;
- (void) drawBrickWall;
- (void) initializeSnakeArray;
- (void) createItem;
- (void) updateSnakeArray;
void ccFilledRect(CGPoint v1, CGPoint v2);

@end
