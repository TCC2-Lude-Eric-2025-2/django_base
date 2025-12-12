from django.urls import include, path
from core.api.v1 import urls as core_api_v1_urls
from core.api.views import auth_frontend

app_name = "core"


urlpatterns = [
    path(
        "v1/",
        include(core_api_v1_urls),
        name="v1",
    ),
    path("login/", auth_frontend.login_page, name="login_page"),
    path("auth/", include("social_django.urls", namespace="social")),
    path("profile/", auth_frontend.profile_page, name="profile"),
]
