//
//  ImageViewCell.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageViewCell : UITableViewCell{
    UIImage*cellsImage;
}

@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) id delegate;
//@property (nonatomic,weak) UIImage *image;

-(id)initWithImage:(UIImage*)image andReuseIdentifier:(NSString*)reuseIdentifier;
-(void)buildCell;
@end
