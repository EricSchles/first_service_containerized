import connexion
from injector import Binder
from flask_injector import FlaskInjector
from connexion.resolver import RestyResolver
from flask_injector import inject

from services.provider import ItemsProvider 


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

if __name__ == '__main__':
    app.run(port=8082, server='gevent')
