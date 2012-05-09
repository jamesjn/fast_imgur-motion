class ImgurUploaderController < UIViewController
  extend FilterDetail 

  attr_accessor :viewImageView

  def viewWillAppear(animated)
    navigationItem.title = 'Imgur file uploader' 
    navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Filter", style:UIBarButtonItemStylePlain, target:self, action:'filterImage')
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action:'seeList')
  end

  def viewDidLoad
    @items = []
    @viewImageView = UIImageView.alloc.init
    @viewImageView.image = load_picture_from "http://i.imgur.com/bbg8Y.jpg"
    @viewImageView.frame = [[10,50],[300,200]]
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
    button_load.frame = [[50, 300],[75,50]]
    view.addSubview(button_load)

    upload_imgur_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    upload_imgur_button.setTitle('Imgur', forState:UIControlStateNormal)
    upload_imgur_button.addTarget(self, action:'uploadImgur', forControlEvents:UIControlEventTouchUpInside)
    upload_imgur_button.frame = [[150, 300],[75,50]]
    view.addSubview(upload_imgur_button)

    @filter_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @filter_button.setTitle('b/w filter', forState:UIControlStateNormal)
    @filter_button.addTarget(self, action:'filter_image', forControlEvents:UIControlEventTouchUpInside)
    @filter_button.frame = [[250,300],[75,50]]
    view.addSubview(@filter_button)
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

  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    image = info.objectForKey(UIImagePickerControllerOriginalImage)
    @viewImageView.setImage(image)
    dismissModalViewControllerAnimated(true)
  end

  def seeList
    7.times do
      addImageItem
    end
    image_list_controller = ImageListController.alloc.init
    image_list_controller.setItems(@items)
    navigationController.pushViewController(image_list_controller, animated:true)
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
