class ImageListController < UITableViewController
  attr_accessor :imgur_list
  
  def init
    if super
      self.tabBarItem = UITabBarItem.alloc.initWithTitle('List', image:nil, tag:2)
    end
    self
  end

  def viewDidLoad
    view.dataSource = view.delegate = self
  end 

  def viewWillAppear(animated)
    self.parentViewController.navigationItem.title = 'Image List' 
    self.parentViewController.navigationItem.leftBarButtonItem = editButtonItem
    self.parentViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Clear", style:UIBarButtonItemStylePlain, target:self, action:'clearItems')

    @items = []
    @imgur_list.each do |item|
      @items << item 
    end
    view.reloadData
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @items.size
  end

  CellID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CellID)
    imageItem = @items[indexPath.row]
    cell.textLabel.text = imageItem
    cell.image = load_picture_from imageItem
    cell
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    @items.delete_at(indexPath.row)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    view.reloadData
  end

  def load_picture_from url
    url = NSURL.URLWithString(url)
    image = UIImage.imageWithData(NSData.dataWithContentsOfURL(url))
  end

  def setItems items
    @items = items
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    item = @items[indexPath.row]
    image_controller = ImageViewController.alloc.init
    image_controller.image_url = item
    navigationController.pushViewController(image_controller, animated:true)
  end

  private

  def addImageItem
    url = "http://i.imgur.com/bbg8Y.jpg"
    @items << url
    view.reloadData
  end

end
