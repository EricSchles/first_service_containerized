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
 
