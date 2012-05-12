class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    #nav = UINavigationController.alloc.initWithRootViewController(ImageListController.alloc.init)
    
    imgur_list = []

    image_list_controller = ImageListController.alloc.init
    imgur_uploader_controller = ImgurUploaderController.alloc.init 
    imgur_uploader_controller.imgur_list = imgur_list
    image_list_controller.imgur_list = imgur_list

    tabbar = UITabBarController.alloc.init
    tabbar.viewControllers = [imgur_uploader_controller, image_list_controller]
    tabbar.selectedIndex = 0 

    nav = UINavigationController.alloc.initWithRootViewController(tabbar)
    nav.wantsFullScreenLayout = true

    @window.rootViewController = nav
    @window.makeKeyAndVisible
    return true
  end
end
