//
//  NMGlyphDetector.m
//  Breckenridge
//
//  Created by Marat Sharifullin on 12/22/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <opencv/cv.h>
#import <opencv/ml.h>


#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NMGlyphSearchViewController.h"
#import "NMGlyphDetector.h"

void findX(IplImage* imgSrc,int* min, int* max);
void findY(IplImage* imgSrc,int* min, int* max);
CvRect findBB(IplImage* imgSrc);
IplImage* preprocessing(IplImage* imgSrc,int new_width, int new_height);

void findX(IplImage* imgSrc,int* min, int* max)
{
    int i;
    int minFound=0;
    CvMat data;
    CvScalar maxVal=cvRealScalar(imgSrc->height * 255);
    CvScalar val=cvRealScalar(0);
    //For each col sum, if sum < width*255 then we find the min
    //then continue to end to search the max, if sum< width*255 then is new max
    for (i=0; i< imgSrc->width; i++){
        cvGetCol(imgSrc, &data, i);
        val= cvSum(&data);
        if(val.val[0] < maxVal.val[0]){
            *max= i;
            if(!minFound){
                *min= i;
                minFound= 1;
            }
        }
    }
}

void findY(IplImage* imgSrc,int* min, int* max)
{
    int i;
    int minFound=0;
    CvMat data;
    CvScalar maxVal=cvRealScalar(imgSrc->width * 255);
    CvScalar val=cvRealScalar(0);
    //For each col sum, if sum < width*255 then we find the min
    //then continue to end to search the max, if sum< width*255 then is new max
    for (i=0; i< imgSrc->height; i++){
        cvGetRow(imgSrc, &data, i);
        val= cvSum(&data);
        if(val.val[0] < maxVal.val[0]){
            *max=i;
            if(!minFound){
                *min= i;
                minFound= 1;
            }
        }
    }
}

CvRect findBB(IplImage* imgSrc)
{
    CvRect aux;
    int xmin, xmax, ymin, ymax;
    xmin=xmax=ymin=ymax=0;
    
    findX(imgSrc, &xmin, &xmax);
    findY(imgSrc, &ymin, &ymax);
    
    aux=cvRect(xmin, ymin, xmax-xmin+1, ymax-ymin+1);
    
    //printf("BB: %d,%d - %d,%d\n", aux.x, aux.y, aux.width, aux.height);
    
    return aux;
    
}

IplImage* preprocessing(IplImage* imgSrc,int new_width, int new_height)
{
    IplImage* result;
    IplImage* scaledResult;
    
    CvMat data;
    CvMat dataA;
    CvRect bb;//bounding box
    
    //Find bounding box
    bb=findBB(imgSrc);
    
    //Get bounding box data and no with aspect ratio, the x and y can be corrupted
    cvGetSubRect(imgSrc, &data, cvRect(bb.x, bb.y, bb.width, bb.height));
    //Create image with this data with width and height with aspect ratio 1
    //then we get highest size betwen width and height of our bounding box
    int size=(bb.width>bb.height)?bb.width:bb.height;
    result=cvCreateImage( cvSize( size, size ), 8, 1 );
    cvSet(result,CV_RGB(255,255,255),NULL);
    //Copy de data in center of image
    int x=(int)floor((float)(size-bb.width)/2.0f);
    int y=(int)floor((float)(size-bb.height)/2.0f);
    cvGetSubRect(result, &dataA, cvRect(x,y,bb.width, bb.height));
    cvCopy(&data, &dataA, NULL);
    //Scale result
    scaledResult=cvCreateImage( cvSize( new_width, new_height ), 8, 1 );
    cvResize(result, scaledResult, CV_INTER_AREA);
    //preprocess color
    for (int i=0; i<scaledResult->width*scaledResult->height; ++i)
    {
        unsigned char br = scaledResult->imageData[i];
        scaledResult->imageData[i] = br > 200 ? 255 : 0;
    }
    
    //Return processed data
    return scaledResult;
    
}

@interface NMGlyphDetector()
{
    CvANN_MLP mlp_16;
    CvANN_MLP mlp_10000;
}
@end

static NMGlyphDetector *_sharedInstance = nil;

@implementation NMGlyphDetector

@synthesize delegate;
@synthesize points;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NMGlyphDetector alloc] init];
    });
}


+ (id) sharedInstance
{
    return _sharedInstance;
}


- (id)init {
    if ((self = [super init]))
    {
        self.points = [[NSMutableArray alloc] init];
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"digits_16_mlp" 
                                                         ofType:@"xml"];
        mlp_16.load([path UTF8String]);

    }
    return self;
}

- (void)dealloc {
}

- (void)addPoint:(CGPoint)point {
    [self.points addObject:[NSValue valueWithCGPoint:point]];
}

- (void)detectGlyph {
    [self addPoints];
    
    CvSize size;
    size.height = 400;
    size.width = 280;
    
    char *char_image = (char *)malloc( size.height*size.width*sizeof(char) );
    memset( char_image, 255, size.height*size.width*sizeof(char) );
    for (NSUInteger i=0; i<[self.points count]; ++i) {
        struct CGPoint p;
        [[self.points objectAtIndex:i] getValue:&p];
        
        char_image[(int)(p.x + p.y*size.width)] = 0;
    }

    
    IplImage* ipl_image_p = cvCreateImageHeader(size, IPL_DEPTH_8U, 1);
    ipl_image_p->imageData = char_image;
    ipl_image_p->imageDataOrigin = ipl_image_p->imageData;
    
    IplImage *scaled_image = preprocessing(ipl_image_p, 100, 100);
    
    CvRect bb = findBB(scaled_image);
    long on_points = 0;
    long mean_x = 0;
    long mean_y = 0;
    long mean_hor_edges = 0;
    long sum_ver_hor_edges = 0;
    long mean_ver_edges = 0;
    long sum_hor_ver_edges = 0;
    for (int x=0; x<scaled_image->width; ++x)
    {
        for (int y=0; y<scaled_image->height; ++y)
        {
            if ((unsigned char)(scaled_image->imageData[x + y*scaled_image->width]) < 126)
            {
                long x_rel = x - (bb.x + bb.width/2);
                long y_rel = y - (bb.y + bb.height/2);
                ++on_points;
                mean_x += x_rel;
                mean_y += y_rel;
                
                if (x==0 || (unsigned char)(scaled_image->imageData[(x-1) + y*scaled_image->width]) < 126)
                {
                    ++mean_hor_edges;
                    sum_ver_hor_edges += y;
                }
                
                if (y==0 || (unsigned char)(scaled_image->imageData[x + (y-1)*scaled_image->width]) < 126)
                {
                    ++mean_ver_edges;
                    sum_hor_ver_edges += x;
                }
            }
        }
    }

    mean_x = mean_x/on_points;
    mean_y = mean_y/on_points;

    long x_variance = 0;
    long y_variance = 0;
    long xy_corr = 0;
    
    long mean_x2y = 0;
    long mean_xy2 = 0;
    
    for (int x=0; x<scaled_image->width; ++x)
    {
        for (int y=0; y<scaled_image->height; ++y)
        {
            if ((unsigned char)(scaled_image->imageData[x + y*scaled_image->width]) < 126)
            {
                long x_rel = x - (bb.x + bb.width/2);
                long y_rel = y - (bb.y + bb.height/2);
                x_variance += (x_rel - mean_x)*(x_rel-mean_x);
                y_variance += (y_rel - mean_y)*(y_rel-mean_y);
                xy_corr += (x_rel-mean_x)*(y_rel-mean_y);
                
                mean_x2y += (x_rel - mean_x)*(x_rel-mean_x)*(y_rel - mean_y);
                mean_xy2 += (x_rel-mean_x)*(y_rel - mean_y)*(y_rel - mean_y);
            }
        }
    }
    
    x_variance = sqrt(x_variance/on_points);
    y_variance = sqrt(y_variance/on_points);
    xy_corr = ((x_variance*y_variance*on_points)==0) ? 0 : (xy_corr*100)/(x_variance*y_variance*on_points);
    
    
    mean_x2y = cbrtl(mean_x2y/on_points);
    mean_xy2 = cbrtl(mean_xy2/on_points);
    
    mean_hor_edges = (mean_hor_edges*100)/on_points;
    sum_ver_hor_edges = sum_ver_hor_edges/on_points;
    
    mean_ver_edges = (mean_ver_edges*100)/on_points;
    sum_hor_ver_edges = sum_hor_ver_edges/on_points;
    
    
    //SCALING HERE
    
    NSLog( @"SVM PARAMS:\n %i %i %i %i\n  %li\n  %li %li\n    %li %li     \n%li  \n%li %li\n   %li  %li\n    %li %li",
          bb.x, bb.y, bb.width, bb.height,
          on_points,
          mean_x, mean_y,
          x_variance, y_variance,
          xy_corr,
          mean_x2y, mean_xy2,
          mean_hor_edges, sum_ver_hor_edges,
          mean_ver_edges, sum_hor_ver_edges );
    NSLog( @"mean_x2y: %li", mean_x2y );
    
    
    if( !mlp_16.get_layer_count() )
    {
        NSLog(@"Could not read the MLP classifier" );
        char results[] = { '?' };
        [delegate firstResults:results size:1];
    }
    else
    {
        NSLog( @"The MLP classifier is loaded" );

        float params[16] =
        {
            bb.x, bb.y, bb.width, bb.height,
            on_points,
            mean_x, mean_y,
            x_variance, y_variance,
            xy_corr,
            mean_x2y, mean_xy2,
            mean_hor_edges, sum_ver_hor_edges,
            mean_ver_edges, sum_hor_ver_edges
        };

        
        int best_class;
        CvMat *sample = cvCreateMat(1, 16, CV_32F);
        for (int i=0; i<16; ++i)
        {
            float* ddata = sample->data.fl;
            ddata[i] = params[i];
        }
        CvPoint max_loc = {0,0};
        CvMat *mlp_response = cvCreateMat( 1, 10, CV_32F );
        mlp_16.predict( sample, mlp_response );
        cvMinMaxLoc( mlp_response, 0, 0, 0, &max_loc, 0 );
        best_class = max_loc.x + '0';
        
        char results[5];
        results[0] = max_loc.x + '0';
        
        [delegate firstResults:results size:1];
    }

//    const char *filename = "/Users/marat/LEARNING/image_data_XXX.txt";
//    bool new_file = true;
//    FILE *file = fopen(filename, "r");
//    if (file)
//    {
//        new_file = false;
//        fclose(file);
//    }
//    file = fopen(filename, "a");
//    if (file) {
//        if (new_file) 
//        {
//            fwrite(&scaled_image->height, sizeof(scaled_image->height), 1, file);
//            fwrite(&scaled_image->width, sizeof(scaled_image->width), 1, file);
//        }
//        fwrite(scaled_image->imageData, 1, scaled_image->width*scaled_image->height, file);
//        fclose(file);
//    }
//
//    {
//        char letter = '0';
//        FILE *file = fopen("/Users/marat/LEARNING/all_data_16_attrs.txt", "a");
//        if (file)
//        {
//            fprintf(file, "%c,%i,%i,%i,%i,%li,%li,%li,%li,%li,%li,%li,%li,%li,%li,%li,%li\n",
//                    letter,
//                    bb.x, bb.y, bb.width, bb.height,
//                    on_points,
//                    mean_x, mean_y,
//                    x_variance, y_variance,
//                    xy_corr,
//                    mean_x2y, mean_xy2,
//                    mean_hor_edges, sum_ver_hor_edges,
//                    mean_ver_edges, sum_hor_ver_edges );
//            fclose(file);
//        }
//        
//        file = fopen("/Users/marat/LEARNING/all_data_10000_attrs.txt", "a");
//        if (file)
//        {
//            fprintf(file, "%c", letter);
//            
//            for (int x=0; x<scaled_image->width; ++x)
//            {
//                for (int y=0; y<scaled_image->height; ++y)
//                {
//                    unsigned char val = ((unsigned char)(scaled_image->imageData[x + y*scaled_image->width]) < 126) ? '0' : '1';
//                    fprintf(file, ",%c", val);
//                }
//            }
//            fprintf(file, "\n");
//            fclose(file);
//        }
//    }

    cvReleaseImageHeader(&ipl_image_p);
    cvReleaseImage(&scaled_image);
    free( char_image );
}

- (void)reset
{
    [self.points removeAllObjects];
}



- (void)addPoints
{
    int prev_x, prev_y;
    
    NSUInteger size = [self.points count];
    for (NSUInteger i=0; i<size; ++i)
    {
        struct CGPoint p;
        [[self.points objectAtIndex:i] getValue:&p];
        
        if (i!=0)
        {
            int x = p.x;
            int y = p.y;
            
            if (abs(x-prev_x) > 1 || abs(y-prev_y) > 1) {
                if (abs(x-prev_x) < 1.0e-5) {
                    int min = MIN(y, prev_y);
                    int max = MAX(y, prev_y);
                    for( int i=min+1; i<max; ++i) {
                        [self.points addObject:[NSValue valueWithCGPoint:CGPointMake(x, i)]];
                    }
                }
                else {
                    float k = (float)(prev_y-y)/(float)(prev_x-x);
                    float b = (float)(-prev_y*x + y*prev_x)/(float)(prev_x-x);
                    float k_abs = fabs(k);
                    if (k_abs < 1) {
                        int min = MIN(x, prev_x);
                        int max = MAX(x, prev_x);
                        for( int i=min+1; i<max; ++i) {
                            int tmpY = (int)(k*(float)i + b);
                            [self.points addObject:[NSValue valueWithCGPoint:CGPointMake(i, tmpY)]];
                        }
                    }
                    else {
                        int min = MIN(y, prev_y);
                        int max = MAX(y, prev_y);
                        for( int i=min+1; i<max; ++i) {
                            int tmpX = (int)((float)(i)/k - (float)(b)/k);
                            [self.points addObject:[NSValue valueWithCGPoint:CGPointMake(tmpX, i)]];
                        }
                    }
                }
            }
        }
        prev_x = p.x;
        prev_y = p.y;
    }
}


@end


