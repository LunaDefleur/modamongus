#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

extern "C" void SetEspEnabled(bool enabled);
extern "C" void SetWideLightEnabled(bool enabled);

@interface ModMenuWindow : UIWindow
@property (nonatomic, strong) UIButton *floatButton;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *espOverlayView;
@end

@implementation ModMenuWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [[UIViewController alloc] init];

        [self setupESPOverlay];
        [self setupFloatButton];
        [self setupMenuView];
    }
    return self;
}

- (void)setupESPOverlay {
    self.espOverlayView = [[UIView alloc] initWithFrame:self.bounds];
    self.espOverlayView.userInteractionEnabled = NO;
    self.espOverlayView.backgroundColor = [UIColor clearColor];
    self.espOverlayView.layer.borderColor = [UIColor redColor].CGColor;
    self.espOverlayView.layer.borderWidth = 0.0;
    [self.rootViewController.view addSubview:self.espOverlayView];
}

- (void)setupFloatButton {
    self.floatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatButton.frame = CGRectMake(50, 100, 60, 60);
    self.floatButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:1.0 alpha:0.85];
    self.floatButton.layer.cornerRadius = 30;
    self.floatButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.floatButton.layer.shadowOpacity = 0.5;
    self.floatButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.floatButton.layer.shadowRadius = 5;
    [self.floatButton setTitle:@"MOD" forState:UIControlStateNormal];
    self.floatButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatButton addGestureRecognizer:pan];
    [self.floatButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.rootViewController.view addSubview:self.floatButton];
}

- (void)setupMenuView {
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(50, 170, 260, 220)];
    self.menuView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.95];
    self.menuView.layer.cornerRadius = 12;
    self.menuView.layer.borderWidth = 1.0;
    self.menuView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.menuView.hidden = YES;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 30)];
    titleLabel.text = @"AMONG US MOD MENU";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.menuView addSubview:titleLabel];

    UILabel *espLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 190, 30)];
    espLabel.text = @"ESP (chưa triển khai)";
    espLabel.textColor = [UIColor whiteColor];
    UISwitch *espSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(160, 60, 51, 31)];
    espSwitch.onTintColor = [UIColor systemGreenColor];
    espSwitch.enabled = NO; // Prevent advertising a non-functional ESP toggle.
    [self.menuView addSubview:espLabel];
    [self.menuView addSubview:espSwitch];

    UILabel *lightLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 150, 30)];
    lightLabel.text = @"Wide Light";
    lightLabel.textColor = [UIColor whiteColor];
    UISwitch *lightSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(160, 110, 51, 31)];
    lightSwitch.onTintColor = [UIColor systemGreenColor];
    [lightSwitch addTarget:self action:@selector(toggleLight:) forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:lightLabel];
    [self.menuView addSubview:lightSwitch];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(0, 170, 260, 40);
    [closeBtn setTitle:@"ĐÓNG" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:closeBtn];

    [self.rootViewController.view addSubview:self.menuView];
}

- (void)toggleMenu {
    self.menuView.hidden = !self.menuView.hidden;
}

- (void)toggleESP:(UISwitch *)sender {
    SetEspEnabled(sender.isOn);
    self.espOverlayView.layer.borderWidth = 0.0;
}

- (void)toggleLight:(UISwitch *)sender {
    SetWideLightEnabled(sender.isOn);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.rootViewController.view];
    CGPoint nextCenter = CGPointMake(self.floatButton.center.x + translation.x,
                                     self.floatButton.center.y + translation.y);
    CGFloat halfW = CGRectGetWidth(self.floatButton.bounds) * 0.5;
    CGFloat halfH = CGRectGetHeight(self.floatButton.bounds) * 0.5;
    CGRect bounds = self.rootViewController.view.bounds;
    nextCenter.x = MIN(MAX(nextCenter.x, halfW), CGRectGetWidth(bounds) - halfW);
    nextCenter.y = MIN(MAX(nextCenter.y, halfH), CGRectGetHeight(bounds) - halfH);
    self.floatButton.center = nextCenter;

    CGFloat menuW = CGRectGetWidth(self.menuView.bounds);
    CGFloat menuH = CGRectGetHeight(self.menuView.bounds);
    CGFloat menuX = MIN(MAX(nextCenter.x - menuW * 0.5, 8.0), CGRectGetWidth(bounds) - menuW - 8.0);
    CGFloat menuY = nextCenter.y + halfH + 10.0;
    if (menuY + menuH > CGRectGetHeight(bounds) - 8.0) {
        menuY = nextCenter.y - halfH - menuH - 10.0;
    }
    menuY = MIN(MAX(menuY, 8.0), CGRectGetHeight(bounds) - menuH - 8.0);
    self.menuView.frame = CGRectMake(menuX, menuY, menuW, menuH);
    [pan setTranslation:CGPointZero inView:self.rootViewController.view];
}
@end

static ModMenuWindow *gModMenu = nil;

extern "C" void initModMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!gModMenu) {
            gModMenu = [[ModMenuWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        gModMenu.hidden = NO;
        [gModMenu makeKeyAndVisible];
    });
}
