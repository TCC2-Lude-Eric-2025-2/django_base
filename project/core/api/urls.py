from django.urls import include, path
from core.api.v1 import urls as core_api_v1_urls
from core.api.views import oauth_google

app_name = "core"


urlpatterns = [
    path(
        "v1/",
        include(core_api_v1_urls),
        name="v1",
    ),
    path("auth/google/login/", oauth_google.google_login, name="google_login"),
    path("auth/google/callback/", oauth_google.google_callback, name="google_callback"),
]
