//
//  ImageViewCell.m
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "ImageViewCell.h"

@implementation ImageViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"Designated initializer: initWithImage: andReuseIdentifier:");
    return [self initWithImage:[UIImage imageNamed:@""] andReuseIdentifier:reuseIdentifier];
}

-(id)initWithImage:(UIImage*)image andReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"ImageTableViewCell" owner:self options:nil];
        self = [cellArray objectAtIndex:0];

        cellsImage = image;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)buildCell
{
    [self.imageView setBackgroundColor:[UIColor clearColor]];
    self.imageView.layer.cornerRadius = 10;
    self.imageView.clipsToBounds = YES;
    [self.imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.imageView.layer setBorderWidth: 0.25];

    [self.imageView setFrame:CGRectMake(self.bounds.origin.x+20, self.bounds.origin.y+10, 280, cellsImage.size.height-20)];
    NSLog(@"%f,%f,%f,%f",self.bounds.origin.x+20, self.bounds.origin.y+10, 280.0, cellsImage.size.height-20);
    NSLog(@"%f,%f,%f,%f",self.imageView.frame.origin.x, self.imageView.frame.origin.y, 280.0, self.imageView.frame.size.height);

    [self.imageView setImage:cellsImage];
}

@end
