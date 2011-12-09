//
//  NMKongiRecognizer.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/1/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NMKongiRecognizerDelegate : NSObject<UIGestureRecognizerDelegate> 

@end


@interface NMKongiRecognizer : UIGestureRecognizer
@property (nonatomic, weak) NMKongiRecognizerDelegate *delegate;

@end
