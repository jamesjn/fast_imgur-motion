class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    #nav = UINavigationController.alloc.initWithRootViewController(ImageListController.alloc.init)
    
    path = itemArchivePath
    imgur_list = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
p imgur_list
    if (!imgur_list)
      imgur_list = []
    end

    image_list_controller = ImageListController.alloc.init
    @imgur_uploader_controller = ImgurUploaderController.alloc.init 
    @imgur_uploader_controller.imgur_list = imgur_list
    image_list_controller.imgur_list = imgur_list

    tabbar = UITabBarController.alloc.init
    tabbar.viewControllers = [@imgur_uploader_controller, image_list_controller]
    tabbar.selectedIndex = 0 

    nav = UINavigationController.alloc.initWithRootViewController(tabbar)
    nav.wantsFullScreenLayout = true

    @window.rootViewController = nav
    @window.makeKeyAndVisible
    return true
  end

  def itemArchivePath
    documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)
    documentDirectory = documentDirectories.objectAtIndex(0)
    documentDirectory.stringByAppendingPathComponent("items.archive")
  end

  def applicationDidEnterBackground(app)
    path = itemArchivePath 
    success = NSKeyedArchiver.archiveRootObject(@imgur_uploader_controller.imgur_list, toFile:path)
    if success
      p "saved all items"
    else
      p "did not save"
    end
  end
  
end
