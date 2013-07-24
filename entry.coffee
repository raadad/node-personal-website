root = global ? window
root.ap = {} if !root.ap?

express = require('express')
routes = require('./routes')
http = require('http')
app = express()

root.secrets = require("./pass").secrets

$ = require 'jquery'

root.ap.email = require('emailjs').server.connect {
	user: root.secrets.em_user
	password:root.secrets.em_pass
	host:"smtp.gmail.com"
	ssl: true
}


root.data = {}

Tumblr = require('tumblr').Tumblr
youtube = require 'youtube-feeds'
gitapi = require 'github'
twit = require 'twit'

root.t = new twit
	consumer_key: root.secrets.tw_consumer_key
	consumer_secret: root.secrets.tw_consumer_secret
	access_token: root.secrets.tw_access_token
	access_token_secret: root.secrets.tw_access_token_secret


root.getBlogs = (cb) ->
	blog = new Tumblr root.secrets.tm_domain, root.secrets.tm_apikey
	blog.posts limit: 99, (error, response) ->
		throw new Error error if error
		root.blogData = response.posts
		root.blogs = {}
		for i in root.blogData
			name = i.title.replace(/\ /g,"-")
			name = name.replace(/\'/g,"")
			i.ename= name
			i.rawText = $(i.body).text()
			i.rawText255 = $(i.body).text().substring(0,255);
			i.img = $(i.body+i.body).find("img").attr("src")
			i.imgalt = $(i.body+i.body).find("img").attr("alt")
			i.img = "http://flickholdr.com/200/200/#{i.ename}" unless i.img?
			i.imgalt = " "
			root.blogs["#{i.slug}"] = i
			cb()


root.getRepos = (cb) ->
	git = new gitapi  
		version: "3.0.0"
		timeout: 5000
	git.authenticate
		type:"basic"
		username:root.secrets.gt_user
		password:root.secrets.gt_pass
	git.repos.getAll user:"raadad" , (err,res) ->
		cb(err,res)



root.refreshPage = ->
	root.data.blog = {}
	root.data.blog2 = []
	root.data.blog10 = []
	root.data.youtube = {}
	root.data.youtube.items = {}
	root.data.tweets = {}
	root.data.tweets3 = {}

	root.getRepos (err,res) ->
		if err? 
			console.log "Githubs failed ",err
		else
			cp = []
			cp.push  i for i in res when (!i.private) and (!i.fork)
			root.data.repos = cp
			console.log "Githubs loaded without issue"

	root.getBlogs ->
		try
			root.data.blog = {}
			root.data.blog2 = []
			root.data.blog10 = []
			root.data.blogs = root.blogs
			x = 0
			for i , c of root.data.blogs
				break if x > 2
				root.data.blog2.push c
				x++
			x = 0
			for i , c of root.data.blogs
				break if x > 10
				root.data.blog10.push c
				x++

		catch e
			console.log e

	youtube.user('raadad1').uploads (err,res) ->
		if err
			console.log "youtube loading failed"
		else
			root.data.youtube = res

	t.get 'statuses/user_timeline' ,  (err,reply) ->
		if err
			console.log "Error with titter ", err
		else
			root.data.tweets = reply
			x = 0
			for i , c of root.tweets
				break if x > 3
				root.tweets3.push c
				x++


recheckBlogs = ->
	setTimeout(proxyCheckBlogs,600000)

proxyCheckBlogs = ->
	root.refreshPage()
	console.log "loading blogs"
	recheckBlogs()



proxyCheckBlogs()


app.configure ->
	app.set 'views', "#{__dirname}/views"
	app.set 'view engine', 'jade'
	app.use express.favicon()
	app.use express.logger('dev')
	app.use require('less-middleware')({ src: __dirname + '/public' })
	app.use express.static(__dirname + '/public')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router


app.configure 'development', ->
	app.use express.errorHandler()

app.get '/', routes.index
app.get '/resume/', routes.resume
app.get '/projects/', routes.projects
app.get '/screencasts/', routes.screen
app.get '/contact/', routes.contact
app.get '/blog/:id?/', routes.blog

app.post '/contact/', routes.contactPost

root.suffix  = process.argv[2]
root.env  = process.argv[3]

if env == "prod"
	http.createServer(app).listen 3212
	console.log "Running #{env} on port 3212"
else
	http.createServer(app).listen 3000
	console.log "Running #{env} on port 3000"
