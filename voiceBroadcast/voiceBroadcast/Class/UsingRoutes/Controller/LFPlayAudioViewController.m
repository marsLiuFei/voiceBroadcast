//
//  BXShowRoutesViewController.m
//  CoachClient
//
//  Created by apple on 2017/10/23.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//  使用scrollview展示路线

#import "LFPlayAudioViewController.h"
#import "CABasicAnimation+Ext.h"
#import "BXChooseRouteModel.h"
#import "BXButton.h"
#import <MapKit/MapKit.h>
#import "BXLocationManager.h"
#import "CLLocation+Sino.h"

@interface LFPlayAudioViewController ()<BDSSpeechSynthesizerDelegate,CLLocationManagerDelegate>
@property (strong,nonatomic) UIScrollView *screenView;
@property (strong,nonatomic) UIView *greenLightView;
@property (strong,nonatomic) UILabel *distanceLabel;
@property (assign,nonatomic) NSInteger nowIndex;//顺序非下标
@property (strong,nonatomic) CLLocation* coor;


@property (assign,nonatomic) BOOL  isFirstIn;//判断当前是否是第一次进入，如果是第一次进入的话，亮点在第一位置，显示距离的label显示第一个的距离

@end
static int h =70;

@implementation LFPlayAudioViewController
-(CLLocation *)coor{
    if (!_coor) {
        _coor = [[CLLocation alloc] init];
    }
    return _coor;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [BDSSpeechSynthesizer releaseInstance];
    [[BXLocationManager manager] stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.nowIndex = 0;
    self.isFirstIn = YES;

    [self creatUI];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self managerLocation];
        [self configureSDK];
    });


}


#pragma mark - - 获取当前位置的经纬度
- (void)managerLocation{
    // 初始化并开始更新
    [BXLocationManager manager].desiredAccuracy = kCLLocationAccuracyBestForNavigation ;
    [BXLocationManager manager].distanceFilter = 1.0;
    [BXLocationManager manager].delegate = self;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [BXLocationManager manager].allowsBackgroundLocationUpdates = YES;
    }

    if ([[BXLocationManager manager] respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [[BXLocationManager manager] requestAlwaysAuthorization];
    }

    //    self.locManager.pausesLocationUpdatesAutomatically = NO;
    [[BXLocationManager manager] startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = locations.lastObject;
    newLocation = [newLocation locationMarsFromEarth];//将位置转换成中国地图
    CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    self.coor = location;

    if (self.nowIndex!=self.usingRouteInfoArray.count) {
        BXChooseRouteModel *model = self.usingRouteInfoArray[self.nowIndex];
        NSArray *lat_lonArray = [model.lat_lon componentsSeparatedByString:@","];//大lon,小lat
        CLLocation *positionLocation = [[CLLocation alloc] initWithLatitude:[lat_lonArray[1] doubleValue] longitude:[lat_lonArray[0] doubleValue]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f 米",[location distanceFromLocation:positionLocation]];

        if ([self.coor distanceFromLocation:positionLocation]<10) {
            if (self.nowIndex<=self.usingRouteInfoArray.count) {
                self.nowIndex++;
                self.distanceLabel.frame = CGRectMake(WIDTH-80, 20+self.nowIndex*h, 70, 30);
                NSArray *array = self.screenView.subviews;
                CGFloat height ;
                for (UIView *mysubview in array) {
                    NSArray *subArray = mysubview.subviews;
                    for (UIView *thirdView in subArray) {
                        if ([thirdView isKindOfClass:[BXButton class]]) {
                            height = thirdView.frame.size.height;
                            if (thirdView.tag<=self.nowIndex) {
                                thirdView.backgroundColor = GREENCOLOR;
                            }else{
                                thirdView.backgroundColor = [UIColor lightGrayColor];
                            }
                        }
                    }
                }
                BXChooseRouteModel *model = self.usingRouteInfoArray[self.nowIndex-1];
                [self speakText:model.content];
                if (self.nowIndex == self.usingRouteInfoArray.count) {
                    self.distanceLabel.hidden = YES;
                }else{
                    self.greenLightView.frame = CGRectMake(10, 25+self.nowIndex*h, 20, 20);

                    self.distanceLabel.hidden = NO;
                    BXChooseRouteModel *model1 = self.usingRouteInfoArray[self.nowIndex];
                    NSArray *lat_lonArray = [model1.lat_lon componentsSeparatedByString:@","];//大lon,小lat
                    CLLocation *positionLocation = [[CLLocation alloc] initWithLatitude:[lat_lonArray[1] doubleValue] longitude:[lat_lonArray[0] doubleValue]];
                    self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f 米",[self.coor distanceFromLocation:positionLocation]];
                }

            }
        }

    }
}




#pragma mark -- 创建整体的UI布局
- (void) creatUI{
    self.screenView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
    self.screenView.userInteractionEnabled = YES;
    self.screenView.backgroundColor = LIGHTGRAY;
    self.screenView.contentSize = CGSizeMake(WIDTH, self.usingRouteInfoArray.count*70);

    for (int i =0; i<self.usingRouteInfoArray.count; i++) {
        [self creatShowListview:i+1];
    }
    [self.view addSubview:self.screenView];
    if (self.isFirstIn) {
        self.greenLightView = [[UIView alloc] initWithFrame:CGRectMake(10, 25, 20, 20)];
        self.greenLightView.layer.masksToBounds = YES;
        self.greenLightView.layer.cornerRadius = 10;
        self.greenLightView.backgroundColor = GREENCOLOR;
        [self.greenLightView.layer addAnimation:[CABasicAnimation opacityForever_Animation:0.5] forKey:nil];
        [self.screenView addSubview:self.greenLightView];
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH-80, 20, 70, 30)];
        self.distanceLabel.font = [UIFont systemFontOfSize:13];
        self.distanceLabel.textColor  = [UIColor orangeColor];
        self.distanceLabel.textAlignment = NSTextAlignmentRight;
        [self.screenView addSubview:self.distanceLabel];

        BXChooseRouteModel *model1 = self.usingRouteInfoArray[0];
        NSArray *lat_lonArray = [model1.lat_lon componentsSeparatedByString:@","];//大lon,小lat
        CLLocation *positionLocation = [[CLLocation alloc] initWithLatitude:[lat_lonArray[1] doubleValue] longitude:[lat_lonArray[0] doubleValue]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f 米",[self.coor distanceFromLocation:positionLocation]];
    }

    if (self.usingRouteInfoArray.count>1) {
        self.distanceLabel.hidden = NO;
    }else{
        self.distanceLabel.hidden = YES;
    }
}


- (void)creatShowListview:(int )index{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, (index-1)*h, WIDTH, h-1)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.userInteractionEnabled = YES;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    btn.frame = CGRectMake(0, 0, WIDTH, h);
    btn.tag = index;
    [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];

    BXButton *lightView = [[BXButton alloc] initWithFrame:CGRectMake(10, 25, 20, 20)];
    lightView.tag = index;
    lightView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lightView];

    UIView *lineviewTop = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 1, 25)];
    lineviewTop.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineviewTop];

    UIView *lineviewBottom = [[UIView alloc] initWithFrame:CGRectMake(20, 45, 1, 25)];
    lineviewBottom.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineviewBottom];


    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 50, 50)];
    BXChooseRouteModel *model = self.usingRouteInfoArray[index-1];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"default_icon"]];
    [bgView addSubview:imageView];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, WIDTH-180, 30)];
    nameLabel.text = model.name;
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:nameLabel];

    [self.screenView addSubview:bgView];
}


- (void)didClickBtn:(UIButton *)sender{
    self.nowIndex = sender.tag;
    self.distanceLabel.frame = CGRectMake(WIDTH-80, 20+self.nowIndex*h, 70, 30);
    NSArray *array = self.screenView.subviews;
    CGFloat height ;
    for (UIView *mysubview in array) {
        NSArray *subArray = mysubview.subviews;
        for (UIView *thirdView in subArray) {
            if ([thirdView isKindOfClass:[BXButton class]]) {
                height = thirdView.frame.size.height;
                if (thirdView.tag<=self.nowIndex) {
                    thirdView.backgroundColor = GREENCOLOR;
                }else{
                    thirdView.backgroundColor = [UIColor lightGrayColor];
                }
            }
        }
    }
    BXChooseRouteModel *model = self.usingRouteInfoArray[sender.tag-1];
    [self speakText:model.content];
    if (self.nowIndex == self.usingRouteInfoArray.count) {
        self.distanceLabel.hidden = YES;
    }else{
        self.greenLightView.frame = CGRectMake(10, 25+self.nowIndex*h, 20, 20);

        self.distanceLabel.hidden = NO;
        BXChooseRouteModel *model1 = self.usingRouteInfoArray[sender.tag];
        NSArray *lat_lonArray = [model1.lat_lon componentsSeparatedByString:@","];//大lon,小lat
        CLLocation *positionLocation = [[CLLocation alloc] initWithLatitude:[lat_lonArray[1] doubleValue] longitude:[lat_lonArray[0] doubleValue]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f 米",[self.coor distanceFromLocation:positionLocation]];
        NSLog(@"当前点击的是那个 %ld  内容是:%@",sender.tag,model.name);
    }


}




#pragma mark -- 配置百度语音播报
-(void)configureSDK{
    //    MYLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [self configureOnlineTTS];
    [self configureOfflineTTS];
}
// 配置在线
-(void)configureOnlineTTS{
    //#error "Set api key and secret key"
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:@"6QMZVkffeR1KttTw9Ud546m7" withSecretKey:@"KZGxNNrtYgGWLfXtYVURI5i04BLK6ZrA"];
}
// 配置离线
-(void)configureOfflineTTS{
    NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_Speech_Female" ofType:@"dat"];
    NSString* offlineEngineTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_Text" ofType:@"dat"];
    NSString* offlineEngineEnglishSpeechData = [[NSBundle mainBundle] pathForResource:@"English_Speech_Female" ofType:@"dat"];
    NSString* offlineEngineEnglishTextData = [[NSBundle mainBundle] pathForResource:@"English_Text" ofType:@"dat"];
    NSString* offlineEngineLicenseFile = [[NSBundle mainBundle] pathForResource:@"offline_engine_tmp_license" ofType:@"dat"];
    NSError* err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineEngineTextData speechDataPath:offlineEngineSpeechData licenseFilePath:offlineEngineLicenseFile withAppCode:@"9990234"]; //
    if (err) {
        return;
    }
    err = [[BDSSpeechSynthesizer sharedInstance] loadEnglishDataForOfflineEngine:offlineEngineEnglishTextData speechData:offlineEngineEnglishSpeechData];
    if (err) {
        return;
    }



    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:BDS_SYNTHESIZER_SPEAKER_FEMALE] forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];


    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:9]
                                                  forKey:BDS_SYNTHESIZER_PARAM_VOLUME];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:5]
                                                  forKey:BDS_SYNTHESIZER_PARAM_SPEED];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:5]
                                                  forKey:BDS_SYNTHESIZER_PARAM_PITCH];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt: BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_16K]
                                                  forKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING ];

}




// 播放失败
- (void)synthesizerErrorOccurred:(NSError *)error
                        speaking:(NSInteger)SpeakSentence
                    synthesizing:(NSInteger)SynthesizeSentence{

    [[BDSSpeechSynthesizer sharedInstance] cancel];
}
//播报语音
- (void)speakText:(NSString *)text{
    [[BDSSpeechSynthesizer sharedInstance] cancel];
    [[BDSSpeechSynthesizer sharedInstance] speakSentence:
     text withError:nil];
}
@end

