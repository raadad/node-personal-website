root = global ? window
root.ap = {} if !root.ap?

exports.index = (req,res) ->
	console.log root.page
	res.render 'index' , data:root.data, page:'Home'

exports.resume = (req,res) ->
	res.render 'resumePage',data:root.data,  page:'Resume' ,summary:"The Official Rap Sheet"
exports.contact = (req,res) ->
	res.render 'contactPage',data:root.data,  page:'Contact' ,summary:"Lets get In-touch"
exports.contactPost = (req,res) ->
	console.log req.body
	res.write("sent")
	res.end()
	message = 
		subject:"Message from elsleiman.com"
		text:"""
			Name:#{req.body.name}
			Email:#{req.body.email}
			Message:
			#{req.body.text}		
			It shouldn't take long for us to process your request and get to calling your referees'
			You will receive an email once your checks have been completed.
			
			If you have any issues or questions please feel free to contact us through support@refspy.com

			An easy way to check on the current status of your referee check, is go to our website:
			www.refspy.com - and login with the details you supplied.
		"""
		from:"#{req.body.email}"
		to:"raadad@elsleiman.com"

	root.ap.email.send message, (e,m)->
		console.log m || e 


exports.screen = (req,res) ->
	res.render 'screenPage',data:root.data,  page:'Screen Casts' ,summary:"Video's I have made to try and help people"


exports.projects = (req,res) ->
	res.render 'projectsPage',data:root.data,  page:'GitHub Projects' ,summary:"Just some things ive worked on"




exports.blog = (req,res) ->
	console.log root.blogs
	item = root.blogs["#{req.params.id}"]
	if item? 
		res.render 'blogItemPage', data:root.data, page:'Blog', summary:item.title, blog:item 
	else 
		res.render 'blogPage' , data:root.data, page:'Blog',summary:"Whats is Ray Elsleiman talking about now?"

###
Express server listening on port 3000
[ { blog_name: 'raadad',
    id: 21408851819,
    post_url: 'http://raadad.tumblr.com/post/21408851819/hello-world',
    type: 'text',
    date: '2012-04-20 00:32:00 GMT',
    timestamp: 1334881920,
    format: 'html',
    reblog_key: 'R1aMDVIg',
    tags: [],
    highlighted: [],
    note_count: 0,
    title: 'Hello World',
    body: '<p>My first post, trying to test the tumblr api! looks niftyÂ <img alt="Lets see if i can pull this into my site" height="305" src="http://areyouhappyatwork.files.wordpress.com/2011/12/happiness_1.jpg" width="456"/></p>' 
  } ]
###