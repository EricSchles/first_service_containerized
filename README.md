# Hello World with Connexion

Hello!  And welcome to this microservice + dependency injection application.  It contains three files (that are relevant):

* app.py
* swagger.yaml
* services/provider.py

Getting started:

To get started simply run:

`python -m pip install pipenv`


`pipenv install -r requirements.txt`


`pipenv run python app.py` 

The above steps install pipenv (our virtual environment), install our dependencies (found in requirements.txt), and run our server, found in app.py

## How it works

`connexion` is a great tool and works very similarly to flask, in that you specify routes in a python file, usually called app.py for small apps and a way to specify routes.  The routes are specified in a seperate file in this case, called swagger.yaml.  However, you can use any name you like for the yaml file, in general.  We reference the yaml file in app.py as:

`app.add_api`

This specification allows us to use our yaml file as a specification for our api.  It's important to note, that what goes into our yaml file matters.  You specify the routes you want your api to call here, as well as the python code that runs said file.  In order to connect python code to a end point specified in the yaml file include the following lines in your specification:

```
paths:
  /name_of_route:
    http_method:
       tags: [defined types that get returned separated by commas]
       operationId: filename.function_name <-- this is the magic!!!
```

By specifying the operationId it connections the python function to the api end point, and then you are good to go.  Why do things this way you might be asking yourself?  Aren't decorator annotations on apps better?!  

Well the honest answer is yes, if your application is small.  But the whole point of microservices is that you trade complexity at the endpoint level for complexity across the application.  This isn't better or worse, it's case specific.  But if you are building thousands of endpoints, this is definitely better, because remembering where everything goes and how it all gets specified and having to search across the entire code base is tough.  
Having the ease of going to a centralized file that's going to make sense to anyone (even if they don't read python) is a good thing.  This way your front end and backend engineers can coordinate without learning everything the other knows.  So it's a very good thing.

## Understanding Dependency Injection

Dependency injection feels a bit too obvious to be a big deal __at first__.  Once you start using it you quickly realize it's super powers:

* obvious and straight foward mocking of objects
* the ability to swap out components as long as they conform to the same interface

This a really big deal - the two aspects of above are really one feature - the ability to ignore the specifics of an object and only care that certain methods are supported by the interface.  This doesn't matter for small scale projects, however as your project grows the ability to only care about the associated interfaces is key to doing "at scale" work over the "long run".  What if the technologies change?  What if your team grows from 5 people to 50?  That's where dependency injection comes into play.

This technique is inline with the general premise of microservices - you do some upfront setup that feels __awful__ for the long term benefits of the short term setup.  In doing so, you make your overall application less explicit and more general (and unfortunately also implicit), but you gain the ability to make it possible for individual contributors to care less about the specifics.  In a way this is like information hiding.  The architects care about all the big changes, but it makes life a lot easier on the individual contributors.  

I think where this can go wrong is when individual contributors don't understand why the details have been abstracted away and due to imposter syndrome (not being amazing at something right away means you never will be and that you are a terrible person and suck at everything) they feel they need to know everything.  Then they look a the highly abstracted code, don't understand and have a meltdown.  But this is very fixable.  All one needs to do is point folks at resources like this one!  And then they two can understand the how you design microservices, but also the why!  Which will help a lot with the imposter syndrome.

Okay, so I talked about the bulleted arguments as to why we care about dependency injection, but how does it work?

Well you specify an object in a file - in this case services/provider.py

In this case the object looks like this:

```
class ItemsProvider:
    def __init__(self, items: list=[]):
       self._items = items
    def get(self, number_of_items:int=5) -> list:
       if not self._items:
         return []

       if number_of_items > len(self._items):
         number_of_items = len(self._items)

       return self._items[:number_of_items] 
```

What does this thing do?  Well, it just returns a list of numbers.  Unless otherwise specified the most it returns is 5 items.  So why all this extra class stuff?  Well, in this case, because it's a mock of a database class.  So you start with the fake database connection, write your code around the faked database connection and then you can add in your database connection later.  

But this does something else really important - it makes writing your tests for your database connection really straight forward.  Writing tests when you don't write your code with tests in mind, makes it much harder to test.  But, by adding your code in this way, with testing made explicit by starting off with mocked objects, mocking your objects later becomes easier.  This is one of those things that sucks to start off with, but makes other things easier, which again is the whole microservices mindset.  It's about not being lazy upfront so you can be lazy later.

So how does this come to play in `app.py`?

```
def configure(binder: Binder) -> Binder:
    binder.bind(
       ItemsProvider,
       ItemsProvider([{"name": "Test 1"}])
    )

@inject
def get_items(data_provider: ItemsProvider) -> list:
    return data_provider.get()

app = connexion.App(__name__)
app.add_api('swagger.yaml', resolver=RestyResolver('api'))
FlaskInjector(app=app.app, modules=[configure])
```

It's worth noting I left off all the import statements, but wanted to focus on just the core pieces that matter.  

The `configure` function is the glue that binds our initialized object to our route - in this case `get_items`.  Notice that we pass the ItemsProvider object as a type annotation.  We don't need to explicitly pass the actual object, the FlaskInjector does this for us via the configure function.  Notice the syntax for binder.bind - object type and the second parameter - the initialized object.  That's because bind, binds the object to it's instance to be injected.

This feels like a lot of work to do what amounts to assignment, but that's because it generalized assignment.  It's kind of like a templated assignment, that allows you to pass anything that conforms to the specification of the object.  Basically, the code becomes generic, which allows for greater separation of concerns - you only care about what you need to care about.  
 
## Understanding Containers - Docker

Docker is technology for lightweight virtualization.  It solves many problems at the expense of further adding complexity to your applications.  The challenge with docker is now you have something else to maintain, but like the other things we've seen throughout, the benefits far outweigh the costs.

Containers are light weight virtual machines that run your code in a way that is ubiquitous across any platform.  They are far from the only solution and in an ideal world, they would be completely unnecessary.  Containerization is a technical solution to a behavioral problem - people won't agree to run code the same way and using the same operating system.  If we did agree on one operating system that was always the most up to date, then docker and containers would have no place in this world.

But unfortunately people don't always get along and very rarely agree on the best technology to use.  There are legitimate instances when you actually can't change out the hardware or run a newer operating system like in the military.  But most of the time, you have a lot of flexibility, we simply choose not to adapt, because confirming to a single standard operating system would be bad.

This is where containers come in - they allow you to say to hell with the choices everyone else made and run things your way, except without having to install an entire operating system just to get your code to run on their machine.  Of course, we don't have full flexility - Mac OSX doesn't run via docker, but windows server and most main stream linux distros do, so we can do almost anything within a "containerized" environment.

The nice part of docker and containerization generally is it follows a nicer version of the old apache servers that you might still see kicking around, except you get a ton more extra stuff, more or less for free.  This is because containers necessarily should be thought of as an execution environment.  They run your code for you, through a highly flexible and configurable environment that is operating system like, but not an OS.

The complexity of docker is it's hard to interrogate what's going on.  Running containers are basically headless, but you can ssh into them (if you configured that) and you can run a shell before you execute your container, to ensure things look right inside the container (from a file structure perspective).

Of course things can still go wrong and they can be hard to work with.  But as was for the previous sections on microservices - the mindset remains the same, we trade upfront cost for ease of use.  Before I knew docker or how it worked, I was able to use it, because other engineers would give me the run command, I would run it and things worked.

I didn't care how the server was working, because I wasn't maintaining or updating the Dockerfile.

So what is this Dockerfile exactly?

It is the new makefile.  If you aren't familiar with C or makefiles, I highly recommend checking them out [starting here](https://www.gnu.org/software/make/manual/html_node/Introduction.html).

Basically the Dockerfile instruments your configuration and tells docker how to configure and bootup your server.  It tells it what commands to run, what things to download and install, and any other shell commands you might like to do.

If you don't know bash already, I highly recommend learning it before deciding to mess around with Dockerfiles.

Once you know bash, setting up Dockerfiles is fairly straight forward.  Here is our dockerfile:

```
FROM python:3.6-alpine AS build

RUN mkdir /code
WORKDIR /code
ADD . /code/
RUN cd /code
RUN apk add --no-cache gcc musl-dev
RUN apk add python3-dev

RUN pip3 install -r requirements.txt

EXPOSE 9090
CMD ["python", "/code/app.py"]
```

It make seem opaque at first, but let's walk through it line by line:

`FROM python:3.6-alpine As build`

This line gets a base image from [dockerhub](https://hub.docker.com/) and downloads it.  You can specify your own docker registry if you have private images at your company that you want to build ontop of, but most of them can be traced back far enough to something on dockerhub.  In this case, we want to ensure we have python installed.  The second semantic part of this, after the ':' is the tag.  In this case we want python 3.6 and we want the alpine linux distribution.  It's odd to specify the language first and the operating system second, but it makes more sense if you care about what language you are executing and less about the underlying low level software.  Which is basically how docker works.  It's really about what you execute, not what you are executing on.

`RUN mkdir /code`

This command 'runs' the command `mkdir` and makes the directory `/code`

`WORKDIR /code`

This command makes the newly created code directory the "root" directory for the project.

`ADD . /code/`

This is basically the same as copy, everything is assumed to be in '.' by default.  For the differences between `COPY` and `ADD` see [this reference](https://medium.freecodecamp.org/dockerfile-copy-vs-add-key-differences-and-best-practices-9570c4592e9e)

`RUN cd /code`

This moves us into the code directory.


`RUN apk add --no-cache gcc`

apk is a package manager for alpine.  Here we install gcc.

`RUN apk add python3-dev`

Here we install the python3-dev package just to be safe.

`RUN pip3 install -r requirements.txt`

Here we install all the python dependencies found in requirements.txt.  Notice that we are free to use this file because it's in the same directory as the Dockerfile.  That's because docker is aware of the local filesystem context.  So when you did the `ADD` command above, we added everything in our currect directory to `/code/` in the Dockerfile.

`EXPOSE 9090`

This exposes the port that is specified in `app.py`.  Note that the exposed port must match what the internal server runs, otherwise you won't be able to hit any of the end points.

`CMD ["python", "/code/app.py"]`

The final command "runs" our server which docker will actually execute.  But symbolically this is the same thing.

Next we need to run the following commands:

`docker build -t [image name] .`

I'm going to specifically run:

`docker build -t app_container .`

But you can name your image whatever you want, just make sure you reference consistently throughout your steps.

The . refers to the current directory, so you need not specify this as the directory you want to build from.  But it's generally accepted as typical.  In larger more complex applications this is of course subject to change.

Once my docker image has been built (this is essentially the typical compilation step in older languages like C or C++) we are free to move onto running our server:

`docker run -it -p 8080:9090 app_container`

This will expose the server as running on port 8080, despite the fact that we actually run "internally" on 9090.  Notice that we specify the same image_name.  The generalization of this:

`docker run -it -p [external port]:[internal port] [image name]`

If you are interested in more on docker, please check out:  https://github.com/EricSchles/devops_notes/blob/master/learning_docker.md

I worked on the above notes with instruction from [Michelle Cone](https://twitter.com/michellemcone).
