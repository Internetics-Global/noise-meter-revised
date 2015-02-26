#import "BCTabBar.h"
@class BCTabBarView;
@class BCTabBarController;

@protocol BCTabBarControllerDelegate <NSObject>
@optional
- (void)tabBarController:(BCTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
@end


@interface BCTabBarController : UIViewController <BCTabBarDelegate>

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) BCTabBar *tabBar;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, retain) BCTabBarView *tabBarView;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) BOOL visible;

@property (weak, nonatomic) id<BCTabBarControllerDelegate> delegate;

@end
