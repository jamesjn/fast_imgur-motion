class ImgurUploader
  attr_accessor :delegate
  attr_accessor :image

  def cgi_escape(str)
    str.gsub(/([^ a-zA-Z0-9_.-]+)/) do
      '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
    end.tr(' ', '+')
  end

  def uploadImage image
    imageData = UIImagePNGRepresentation(image) 
    imageStr = imageData.base64Encoding
    #image64Bstr = [imageStr].pack('m')
    imageStr = cgi_escape(imageStr)
    data = {key:'b1507316815a853a7a23318ff905a486', image:imageStr}
p "HEEEEEEEEEEEEEEELLLLO"
    BubbleWrap::HTTP.post("http://api.imgur.com/2/upload.json", {payload: data}) do |response|
      if response.ok?
        returned_str = response.body.to_str
        p returned_str
        json = BubbleWrap::JSON.parse(returned_str)
        p json
        original = json["original"]
        delegate.imageUploadedWithURLString(original)
      else
        alert(response.error_message)
      end
    end
    #NSLog("%@", imageStr)
    ##uploadCall = NSString.stringWithFormat("key=b1507316815a853a7a23318ff905a486&image=%@", imageStr)
    #Dispatch::Queue.main.sync do
    #  uploadCall = "key=b1507316815a853a7a23318ff905a486&image="+imageStr
    #  request = NSMutableURLRequest.requestWithURL(NSURL.URLWithString("http://api.imgur.com/2/upload"))
    #  request.setHTTPMethod("POST")
    #  request.setValue(NSString.stringWithFormat("%d", uploadCall.length), forHTTPHeaderField:("Content-length"))
    #  request.setHTTPBody(uploadCall.dataUsingEncoding(NSUTF8StringEncoding))
    #  theConnection = NSURLConnection.alloc.initWithRequest(request, delegate:self)
    #  if(theConnection)
    #    @receivedData = NSMutableData.data
    #  end
    #end
  end

  def connection(connection, didReceiveData:data)
    @receivedData.appendData(data)
    NSLog("Did receieve data")
  end

  def connectionDidFinishLoading(connection)
    parser = NSXMLParser.alloc.initWithData(@receivedData)
    parser.setDelegate(self)
    parser.parse
    NSLog("Did finish loading")
  end

  def parserDidEndDocument(parser)
    NSLog("Did finish parsing")
    NSLog("%s", @imageURL)
    delegate.imageUploadedWithURLString(@imageURL)
  end

  def parser(parser, didStartElement:elementName, namespaceURI:namespaceURI, qualifiedName:qName, attributes:attributeDict)
    @currentNode = elementName
  end

  def parser(parser, didEndElement:elementName, namespaceURI:namespaceURI, qualifiedName:qName)
    if(@currentNode.isEqualToString(elementName))
      @currentNode = ""
    end
  end

  def parser(parser, foundCharacters:string)
    if(@currentNode.isEqualToString("original"))
      NSLog("found characters")
      NSLog(string)
      @imageURL = string
    end 
  end

end
