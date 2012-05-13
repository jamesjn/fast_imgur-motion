class ImgurUploaderController < UIViewController
  extend FilterDetail 
  attr_accessor :viewImageView
  attr_accessor :imgur_list

  def init
    if super
      self.tabBarItem = UITabBarItem.alloc.initWithTitle('Uploader', image:nil, tag:1)
    end
    self
  end

  def viewWillAppear(animated)
    self.parentViewController.navigationItem.title = 'Imgur file uploader' 
    self.parentViewController.navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithTitle("New", style:UIBarButtonItemStylePlain, target:self, action:'newImage')
    self.parentViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Email", style:UIBarButtonItemStylePlain, target:self, action:'sendEmail')
  end

  def viewDidLoad
    @items = []
    @viewImageView = UIImageView.alloc.init
    #@viewImageView.image = load_picture_from "http://i.imgur.com/bbg8Y.jpg"
    @viewImageView.frame = [[50,50],[150,200]]
    view.addSubview(@viewImageView)

    url_label = UILabel.new
    url_label.font = UIFont.systemFontOfSize(20)
    url_label.text = 'URL'
    url_label.textAlignment = UITextAlignmentCenter
    url_label.textColor = UIColor.whiteColor
    url_label.backgroundColor = UIColor.clearColor
    url_label.frame = [[10, 250], [300,50]]
    view.addSubview(url_label)
    
    @url_label = url_label

    button_load = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    button_load.setTitle('Camera', forState:UIControlStateNormal)
    button_load.addTarget(self, action:'useCamera', forControlEvents:UIControlEventTouchUpInside)
    button_load.frame = [[10, 300],[75,25]]
    view.addSubview(button_load)

    upload_imgur_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    upload_imgur_button.setTitle('Imgur', forState:UIControlStateNormal)
    upload_imgur_button.addTarget(self, action:'uploadImgur', forControlEvents:UIControlEventTouchUpInside)
    upload_imgur_button.frame = [[110, 300],[75,25]]
    view.addSubview(upload_imgur_button)

    @filter_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @filter_button.setTitle('b/w filter', forState:UIControlStateNormal)
    @filter_button.addTarget(self, action:'filterImage', forControlEvents:UIControlEventTouchUpInside)
    @filter_button.frame = [[210,300],[75,25]]
    view.addSubview(@filter_button)

    tb = UIToolbar.alloc.init
    tb.frame = [[0,0],[320,44]]
    tb.center = [160,22] 
    tbitems = NSMutableArray.array
    
    barbutton1 = UIBarButtonItem.alloc.initWithTitle("sephia", style:UIBarButtonItemStylePlain, target:self, action:'doSephia')
    barbutton2 = UIBarButtonItem.alloc.initWithTitle("b/w", style:UIBarButtonItemStylePlain, target:self, action:'doBW')
    tbitems.addObject(barbutton1)
    tbitems.addObject(barbutton2)

    bbi = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil)
    bbi.width = 20
    tbitems.addObject(bbi)

    tb.items = tbitems
    self.view.addSubview(tb)

  end

  def filterImage

    filteredImage = CIImage.alloc.initWithCGImage(@viewImageView.image.CGImage, options:nil)
    filter = CIFilter.filterWithName("CISepiaTone")
    filter.setDefaults()
    filter.setValue(filteredImage, forKey:"inputImage")
    filter.setValue(NSNumber.numberWithFloat(1.0), forKey:"inputIntensity")
    outputImage = filter.valueForKey("outputImage")
    
    context = CIContext.contextWithOptions(nil)

    imgRef = context.createCGImage(outputImage, fromRect:(outputImage.extent))
    originalOrientation = @viewImageView.image.imageOrientation
    @viewImageView.image = UIImage.alloc.initWithCGImage(imgRef, scale:1.0, orientation:originalOrientation)
  end

  def uploadImgur
    imgur_uploader = ImgurUploader.alloc.init
    imgur_uploader.delegate = self
    imgur_uploader.uploadImage(@viewImageView.image)
  end

  def imageUploadedWithURLString(image_url) 
    @url_label.text = image_url 
    @imgur_list << image_url
  end

  def useCamera
    imagePicker = UIImagePickerController.alloc.init
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      imagePicker.setSourceType(UIImagePickerControllerSourceTypeCamera)
    else
      imagePicker.setSourceType(UIImagePickerControllerSourceTypePhotoLibrary)
    end

    imagePicker.mediaTypes = [KUTTypeImage]
    imagePicker.delegate = self
    presentModalViewController(imagePicker, animated:true)
  end

  def scaleToSize(image, size)
    UIGraphicsBeginImageContext(size)
    #context = UIGraphicsGetCurrentContext();
    #CGContextTranslateCTM(context, 0.0, size[1])
    #CGContextScaleCTM(context, 1.0, -1.0)

    #image.drawInRect([0,0], size])
    #CGContextDrawImage(context, CGRectMake(0, 0, 480, 640), image.CGImage) 
    image.drawInRect([[0,0], size])
    scaledImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()
    
    scaledImage
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    image = info.objectForKey(UIImagePickerControllerOriginalImage)
    smaller_image = scaleToSize(image, [480, 640])
    #smaller_image = UIImage.imageWithCGImage(image.CGImage, scale:0.1, orientation:(image.imageOrientation))
    @viewImageView.setImage(smaller_image)
    dismissModalViewControllerAnimated(true)
  end

  def mailComposeController(controller, didFinishWithResult:result, error:error)
    self.dismissModalViewControllerAnimated(true)
  end

  def sendEmail
    if(MFMailComposeViewController.canSendMail) 
      mailer = MFMailComposeViewController.alloc.init
      mailer.mailComposeDelegate = self
      mailer.setSubject("Email from imgur")
      emailBody = @url_label.text
      mailer.setMessageBody(emailBody, isHTML:false)
      self.presentModalViewController(mailer, animated:true)
    else
      alert = UIAlertView.alloc.initWithTitle("Failure", message:"Your device can't send me", delegate:nil, cancelButton:"Ok", otherButtonTitles:nil)
      alert.show
    end
  end


  private

  def load_picture_from url
    url = NSURL.URLWithString(url)
    @image = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
  end

  def addImageItem
    @item = [] if @item.nil?
    url = "http://i.imgur.com/bbg8Y.jpg"
    @items << url
  end
  
end
