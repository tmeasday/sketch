UPLOAD_URL = 'http://api.flickr.com/services/upload'

_prepareArgs = (args) ->
  args.api_key = process.env.FLICKR_KEY
  input = process.env.FLICKR_SECRET
  for key in _.keys(args).sort() when key != 'photo'
    input += key + args[key]
  
  args.api_sig = CryptoJS.MD5(input).toString()

# use this guy to 
Meteor.callFlickr = (args, url = 'http://api.flickr.com/services/rest/') ->
  _prepareArgs(args)
  
  # uncomment this to just see the url it's going to use
  # params = ("#{key}=#{value}" for key, value of args).join('&')
  # console.log "#{url}?#{params}"
  
  Meteor.http.post url, {params: args}, (err, result) ->
    console.log(err)
    console.log(result)
    
Meteor.postFlickr = (args, photo) ->
  # add the token that allows us to post to this account
  args.auth_token = process.env.FLICKR_TOKEN
  _prepareArgs(args)
  
  data = photo.replace(/^data:image\/\w+;base64,/, '')
  photoBuffer = Buffer(data, 'base64')
  
  request = __meteor_bootstrap__.require('request')
  fut = new Future;
  callback = (error, result) ->
    console.log(error) if error
    fut.ret(result)
  
  r = request.post(UPLOAD_URL, callback)
  
  form = r.form()
  form.append(key, value) for key, value of args
  
  # slight hack
  photoBuffer.path = 'photo.png'
  form.append('photo', photoBuffer)
  
  # wait for the upload to complete
  result = fut.wait()
  photoid = result.body.match(/\<photoid\>(\d+)\<\/photoid\>/)[1]
  
  
  # construct a multipart request
  # boundary = Meteor.uuid()
  # content = "--#{boundary}\n"
  # 
  # photo.replace('data:image/jpg;base64,', '');
  # bytes = Buffer(photo, 'base64').toString('binary')
  # 
  # # add the params
  # for key, value of args
  #   content += "Content-Disposition: form-data; name=\"#{key}\"\n\n#{value}\n"
  #   content += "--#{boundary}\n"
  # 
  # # now add the photo
  # content += "Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\n"
  # content += "Content-Type: image/jpg\n\n"
  # content += "#{bytes}\n--#{boundary}--\n"
  # 
  # content = Array.prototype.map.call content, (c) -> 
  #   return c.charCodeAt(0) & 0xff;
  # content = new Uint8Array(content).buffer  
  # console.log(content)
  # 
  # Meteor.http.post UPLOAD_URL, {
  #   headers: {'Content-Type': "multipart/form-data; boundary=#{boundary}"},
  #   content: content
  # }, (err, result) ->
  #   console.log(err)
  #   console.log(result)
  #   