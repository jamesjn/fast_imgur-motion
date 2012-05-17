class ImageViewController < UIViewController
  attr_accessor :image_url
  def viewDidLoad
    self.parentViewController.navigationItem.title = 'Image View' 
    @viewImageView = UIImageView.alloc.init
    @viewImageView.frame = [[50,50],[250,300]]
    @viewImageView.image = load_picture_from @image_url 
    view.addSubview(@viewImageView)
  end
end 

private

def load_picture_from url
  url = NSURL.URLWithString(url)
  @image = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
end
